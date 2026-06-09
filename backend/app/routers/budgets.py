from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from .. import models, schemas, auth
from ..database import get_db

router = APIRouter(prefix="/budgets", tags=["budgets"])

@router.post("/", response_model=schemas.BudgetOut, status_code=201)
def create_budget(
    b: schemas.BudgetCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    new_budget = models.Budget(
        user_id=current_user.id,
        category_id=b.category_id,
        amount=b.amount,
        month=b.month,
    )
    db.add(new_budget)
    db.commit()
    db.refresh(new_budget)
    cat = db.query(models.Category).get(b.category_id)
    return {
        "id": new_budget.id,
        "user_id": new_budget.user_id,
        "category_id": new_budget.category_id,
        "category_name": cat.name if cat else "Unknown",
        "amount": new_budget.amount,
        "month": new_budget.month,
    }

@router.get("/", response_model=list[schemas.BudgetOut])
def list_budgets(
    month: str | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    q = db.query(models.Budget).filter(models.Budget.user_id == current_user.id)
    if month:
        q = q.filter(models.Budget.month == month)
    budgets = q.all()
    result = []
    for b in budgets:
        cat = db.query(models.Category).get(b.category_id)
        result.append({
            "id": b.id,
            "user_id": b.user_id,
            "category_id": b.category_id,
            "category_name": cat.name if cat else "Unknown",
            "amount": b.amount,
            "month": b.month,
        })
    return result
