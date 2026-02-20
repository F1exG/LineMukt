from sqlalchemy.orm import Session
from models import User
from schemas import UserRegister
import hashlib

def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

def create_user(db: Session, user: UserRegister):
    hashed_password = hash_password(user.password)
    db_user = User(
        name=user.full_name,
        email=user.email,
        phone=user.phone,
        hashed_password=hashed_password,
        role="patient"
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()

def get_user_by_id(db: Session, user_id: int):
    return db.query(User).filter(User.id == user_id).first()

def verify_password(plain_password: str, hashed_password: str):
    return hash_password(plain_password) == hashed_password

def authenticate_user(db: Session, email: str, password: str):
    user = get_user_by_email(db, email)
    if not user or not verify_password(password, user.hashed_password):
        return False
    return user

def get_department_by_id(db: Session, department_id: int):
    from models import Department
    return db.query(Department).filter(Department.id == department_id).first()

def get_departments(db: Session):
    from models import Department
    return db.query(Department).all()

def create_queue_entry(db: Session, user_id: int, department_id: int, estimated_wait: int, confidence: int):
    from models import Queue
    
    # ✅ FIX: Use department_id as prefix (unique per department)
    waiting_in_dept = db.query(Queue).filter(
        Queue.department_id == department_id, 
        Queue.status == "waiting"
    ).count()
    
    position_in_dept = waiting_in_dept + 1
    token_number = f"D{department_id:02d}{position_in_dept:03d}"  # D01001, D02001, D03001...
    
    queue_entry = Queue(
        patient_id=user_id,
        department_id=department_id,
        token_number=token_number,  # ✅ Unique: D01001, D02001, D03001...
        position=position_in_dept,
        estimated_wait_time=estimated_wait,
        ai_confidence=confidence,
        status="waiting"
    )
    db.add(queue_entry)
    db.commit()
    db.refresh(queue_entry)
    return queue_entry

def get_user_queue_position(db: Session, user_id: int):
    from models import Queue
    return db.query(Queue).filter(Queue.patient_id == user_id, Queue.status.in_(["waiting", "in-progress"])).first()

def get_queue_stats(db: Session):
    from models import Queue
    served = db.query(Queue).filter(Queue.status == "completed").count()
    in_queue = db.query(Queue).filter(Queue.status.in_(["waiting", "in-progress"])).count()
    return {"served": served, "in_queue": in_queue}