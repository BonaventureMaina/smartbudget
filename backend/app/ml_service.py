import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.naive_bayes import MultinomialNB
from sklearn.pipeline import Pipeline
from sqlalchemy.orm import Session
from . import models

def _train_classifier(user_id: int, db: Session):
    transactions = (
        db.query(models.Transaction)
        .filter(
            models.Transaction.user_id == user_id,
            models.Transaction.category_id.isnot(None),
            models.Transaction.description.isnot(None),
        )
        .all()
    )
    if len(transactions) < 5:
        return None

    df = pd.DataFrame([(t.description, t.category_id) for t in transactions],
                      columns=["description", "category_id"])
    pipeline = Pipeline([
        ("tfidf", TfidfVectorizer(stop_words="english", max_features=500)),
        ("clf", MultinomialNB()),
    ])
    pipeline.fit(df["description"], df["category_id"])
    return pipeline


def predict_category(user_id: int, description: str, db: Session) -> int | None:
    pipeline = _train_classifier(user_id, db)
    if pipeline is None:
        return None
    try:
        pred = pipeline.predict([description])[0]
        return int(pred)
    except Exception:
        return None


def forecast_spending(user_id: int, db: Session):
    from statsmodels.tsa.holtwinters import SimpleExpSmoothing
    import numpy as np

    transactions = (
        db.query(models.Transaction)
        .filter(
            models.Transaction.user_id == user_id,
            models.Transaction.type == models.TransactionType.EXPENSE,
        )
        .all()
    )
    if len(transactions) < 3:
        return None

    df = pd.DataFrame([(t.date.strftime("%Y-%m"), t.amount) for t in transactions],
                      columns=["month", "amount"])
    monthly = df.groupby("month")["amount"].sum().reset_index()
    monthly = monthly.sort_values("month")
    if len(monthly) < 3:
        return None

    model = SimpleExpSmoothing(monthly["amount"].astype(float)).fit()
    forecast = model.forecast(1)  # returns a scalar (numpy float or array of length 1)
    # Handle both scalar and array cases robustly
    try:
        val = forecast.item()   # safest: extracts a Python scalar
    except AttributeError:
        val = forecast
    return float(val) if val is not None and not np.isnan(val) else None
