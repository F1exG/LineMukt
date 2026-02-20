from pydantic import BaseModel
from typing import Optional

class UserRegister(BaseModel):
    full_name: str
    email: str
    phone: str
    password: str

class UserLogin(BaseModel):
    email: str
    password: str

class UserResponse(BaseModel):
    id: int
    full_name: str
    email: str
    phone: str
    
    class Config:
        from_attributes = True

class DepartmentResponse(BaseModel):
    id: str
    name: str
    description: str
    
    class Config:
        from_attributes = True

class WaitTimeResponse(BaseModel):
    department_id: str
    average_wait_time: int
    
    class Config:
        from_attributes = True

class QueueResponse(BaseModel):
    token_number: str
    position: int
    department_id: str
    
    class Config:
        from_attributes = True