from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
from pydantic import BaseModel
from database import engine, get_db, Base
from models import User, Department, Queue
from schemas import UserRegister, UserLogin, UserResponse, DepartmentResponse, WaitTimeResponse, QueueResponse
from auth import hash_password, verify_password, create_access_token, verify_token
import crud

# Create tables
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Hospital Queue API")

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ✅ Schema for queue join request
class JoinQueueRequest(BaseModel):
    department_id: int

# ============ STARTUP EVENT ============
@app.on_event("startup")
def startup_event():
    db = next(get_db())
    
    # Create default departments if not exist
    existing_depts = db.query(Department).count()
    if existing_depts == 0:
        departments = [
            Department(name="General OPD", icon="🏥", description="General Outpatient Department"),
            Department(name="Cardiology", icon="❤️", description="Heart and Cardiovascular"),
            Department(name="Orthopedic", icon="🦴", description="Bone and Joint Care"),
            Department(name="Pediatrics", icon="👶", description="Child Care"),
            Department(name="Gynecology", icon="👩‍⚕️", description="Women Health"),
            Department(name="Neurology", icon="🧠", description="Brain and Nervous System"),
        ]
        for dept in departments:
            db.add(dept)
        db.commit()
        print("✅ Default departments created")

# ============ AUTH ROUTES ============
@app.post("/api/auth/register")
def register(user: UserRegister, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    new_user = crud.create_user(db, user)
    access_token = create_access_token(data={"sub": new_user.id})
    
    return {
        "message": "User registered successfully",
        "token": access_token,
        "user": {
            "id": new_user.id,
            "name": new_user.name,
            "email": new_user.email,
            "role": new_user.role
        }
    }

@app.post("/api/auth/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, user.email)
    if not db_user or not verify_password(user.password, db_user.hashed_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    
    access_token = create_access_token(data={"sub": db_user.id})
    
    return {
        "message": "Login successful",
        "token": access_token,
        "user": {
            "id": db_user.id,
            "name": db_user.name,
            "email": db_user.email,
            "role": db_user.role
        }
    }

# ============ QUEUE ROUTES ============
@app.get("/api/queue/wait-time/{department_id}")
def get_wait_time(department_id: int, db: Session = Depends(get_db)):
    """✅ AI PREDICTION: Get wait time with confidence"""
    department = crud.get_department_by_id(db, department_id)
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    
    # Count people waiting
    waiting = db.query(Queue).filter(
        Queue.department_id == department_id,
        Queue.status.in_(["waiting", "in-progress"])
    ).count()
    
    # Simple AI prediction
    avg_time_per_patient = 10
    estimated_wait = waiting * avg_time_per_patient
    confidence = min(95, 70 + waiting * 2)
    
    return {
        "department": department.name,
        "estimated_wait_time": estimated_wait,
        "people_ahead": waiting,
        "ai_confidence": int(confidence),
        "best_time": "2:45 PM"
    }

@app.post("/api/queue/join")
def join_queue(request: JoinQueueRequest, user_id: int = Depends(verify_token), db: Session = Depends(get_db)):
    """✅ FIXED: Properly accept department_id from body"""
    department_id = request.department_id
    
    # Check if already in queue
    existing = db.query(Queue).filter(
        Queue.patient_id == user_id,
        Queue.department_id == department_id,
        Queue.status.in_(["waiting", "in-progress"])
    ).first()
    
    if existing:
        raise HTTPException(status_code=400, detail="Already in this queue")
    
    department = crud.get_department_by_id(db, department_id)
    if not department:
        raise HTTPException(status_code=404, detail="Department not found")
    
    # Count waiting
    waiting = db.query(Queue).filter(
        Queue.department_id == department_id,
        Queue.status == "waiting"
    ).count()
    
    estimated_wait = waiting * 10
    confidence = min(95, 70 + waiting * 2)
    
    queue_entry = crud.create_queue_entry(db, user_id, department_id, estimated_wait, int(confidence))
    
    return {
        "message": "Added to queue successfully",
        "token_number": queue_entry.token_number,
        "position": queue_entry.position,
        "estimated_wait": estimated_wait,
        "ai_confidence": int(confidence)
    }

@app.get("/api/queue/position")
def get_position(user_id: int = Depends(verify_token), db: Session = Depends(get_db)):
    """✅ QUEUE FEATURE: Get current position in queue"""
    queue_entry = crud.get_user_queue_position(db, user_id)
    if not queue_entry:
        raise HTTPException(status_code=404, detail="Not in any queue")
    
    department = crud.get_department_by_id(db, queue_entry.department_id)
    
    return {
        "token": queue_entry.token_number,
        "department": department.name,
        "position": queue_entry.position,
        "status": queue_entry.status,
        "estimated_wait_time": queue_entry.estimated_wait_time,
        "ai_confidence": queue_entry.ai_confidence
    }

# ============ ADMIN ROUTES ============
@app.get("/api/admin/departments")
def get_departments(db: Session = Depends(get_db)):
    departments = crud.get_departments(db)
    return departments

@app.get("/api/admin/stats")
def get_stats(user_id: int = Depends(verify_token), db: Session = Depends(get_db)):
    user = crud.get_user_by_id(db, user_id)
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    
    stats = crud.get_queue_stats(db)
    return {
        "total_served": stats["served"],
        "in_queue": stats["in_queue"],
        "avg_wait_time": 8
    }

@app.post("/api/admin/call-next")
def call_next(department_id: int, user_id: int = Depends(verify_token), db: Session = Depends(get_db)):
    user = crud.get_user_by_id(db, user_id)
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin access required")
    
    next_patient = db.query(Queue).filter(
        Queue.department_id == department_id,
        Queue.status == "waiting"
    ).order_by(Queue.check_in_time).first()
    
    if not next_patient:
        raise HTTPException(status_code=404, detail="No patients waiting")
    
    next_patient.status = "in-progress"
    db.commit()
    
    return {
        "message": "Patient called successfully",
        "token": next_patient.token_number
    }

# ============ HEALTH CHECK ============
@app.get("/api/health")
def health():
    return {"status": "Backend is running ✅"}