from datetime import datetime
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session

from .. import models, schemas, auth, ml_service
from ..database import get_db

router = APIRouter(prefix="/transactions", tags=["transactions"])


@router.post("/", response_model=schemas.TransactionOut, status_code=201)
def create_transaction(
    txn: schemas.TransactionCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    # Auto-categorize using ML if no category provided
    category_id = txn.category_id
    if category_id is None and txn.description:
        category_id = ml_service.predict_category(current_user.id, txn.description, db)

    new_txn = models.Transaction(
        user_id=current_user.id,
        amount=txn.amount,
        type=txn.type,
        description=txn.description,
        category_id=category_id,
        date=txn.date or datetime.utcnow(),
    )
    db.add(new_txn)
    db.commit()
    db.refresh(new_txn)
    return new_txn


@router.get("/", response_model=list[schemas.TransactionOut])
def list_transactions(
    skip: int = 0,
    limit: int = 100,
    type: Optional[models.TransactionType] = Query(None),
    category_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    q = db.query(models.Transaction).filter(models.Transaction.user_id == current_user.id)
    if type:
        q = q.filter(models.Transaction.type == type)
    if category_id:
        q = q.filter(models.Transaction.category_id == category_id)
    return q.order_by(models.Transaction.date.desc()).offset(skip).limit(limit).all()


@router.get("/forecast")
def get_forecast(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(auth.get_current_user),
):
    forecast = ml_service.forecast_spending(current_user.id, db)
    if forecast is None:
        return {"message": "Not enough data for a forecast"}
    return {"next_month_spending_forecast": round(forecast, 2)}
