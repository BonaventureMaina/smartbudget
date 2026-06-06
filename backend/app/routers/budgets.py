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
    return new_budget


@router.get("/", response_model=list[schemas.BudgetOut])
def list_budgets(
    month: str | None = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    q = db.query(models.Budget).filter(models.Budget.user_id == current_user.id)
    if month:
        q = q.filter(models.Budget.month == month)
    return q.all()
