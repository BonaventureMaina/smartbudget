from app.database import engine, Base
from app import models  # noqa: F401 – ensures models are registered

def init_db():
    Base.metadata.create_all(bind=engine)
    print("All tables created successfully.")

if __name__ == "__main__":
    init_db()
