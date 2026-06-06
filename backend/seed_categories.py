from app.database import SessionLocal
from app.models import Category

def seed():
    db = SessionLocal()
    defaults = ["Food", "Transport", "Utilities", "Entertainment", "Salary", "Shopping", "Health", "Other"]
    for name in defaults:
        if not db.query(Category).filter(Category.name == name).first():
            db.add(Category(name=name))
    db.commit()
    db.close()
    print("Default categories seeded.")

if __name__ == "__main__":
    seed()
