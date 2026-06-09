from datetime import datetime
from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str

class UserOut(BaseModel):
    id: int
    username: str
    email: str
    model_config = {"from_attributes": True}

class UserLogin(BaseModel):
    username: str
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    username: str | None = None

class TransactionCreate(BaseModel):
    amount: float
    type: str
    description: str | None = None
    category_id: int | None = None
    date: datetime | None = None

class TransactionOut(BaseModel):
    id: int
    user_id: int
    amount: float
    type: str
    description: str | None
    category_id: int | None
    date: datetime
    model_config = {"from_attributes": True}

class BudgetCreate(BaseModel):
    category_id: int
    amount: float
    month: str  # YYYY-MM

class BudgetOut(BaseModel):
    id: int
    user_id: int
    category_id: int
    category_name: str
    amount: float
    month: str
    model_config = {"from_attributes": True}
