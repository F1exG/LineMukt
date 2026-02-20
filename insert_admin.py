from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base, User
import hashlib

# Database setup
DATABASE_URL = "sqlite:///./test.db"  # Match your main.py
engine = create_engine(DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create tables
Base.metadata.create_all(bind=engine)

# Simple SHA256 hashing
def hash_password(password: str) -> str:
    return hashlib.sha256(password.encode()).hexdigest()

# Insert admin
db = SessionLocal()
admin_user = User(
    name="Admin User",  # ✅ CHANGED from full_name
    email="admin@hospital.com",
    phone="+977-9800000000",
    hashed_password=hash_password("admin123"),
    role="admin"  # ✅ ADD ROLE
)
db.add(admin_user)
db.commit()
db.refresh(admin_user)
print(f"✅ Admin created: {admin_user.email}")
db.close()