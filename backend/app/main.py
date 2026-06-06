from fastapi import FastAPI

from .routers import auth, users, transactions, budgets

app = FastAPI(title="SmartBudget API", version="0.1.0")

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(transactions.router)
app.include_router(budgets.router)


@app.get("/health")
async def health_check():
    return {"status": "ok"}
