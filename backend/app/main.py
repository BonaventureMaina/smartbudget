from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from .database import engine, Base, SessionLocal
from .routers import auth, users, transactions, budgets, categories
from . import models

app = FastAPI(title="SmartBudget API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(transactions.router)
app.include_router(budgets.router)
app.include_router(categories.router)


@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)
    # Seed default categories if table is empty
    db: Session = SessionLocal()
    try:
        if db.query(models.Category).count() == 0:
            defaults = ["Food", "Transport", "Utilities", "Entertainment", "Salary", "Shopping", "Health", "Other"]
            for name in defaults:
                db.add(models.Category(name=name))
            db.commit()
    finally:
        db.close()


@app.get("/health")
async def health_check():
    return {"status": "ok"}
