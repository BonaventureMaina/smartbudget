[![Backend CI](https://github.com/BonaventureMaina/smartbudget/actions/workflows/test.yml/badge.svg)](https://github.com/BonaventureMaina/smartbudget/actions/workflows/test.yml)

# SmartBudget – AI‑Powered Personal Finance Manager

A production‑grade full‑stack application built with **Flutter**, **FastAPI**, **PostgreSQL**, **Redis**, and **AI/ML** (scikit‑learn + statsmodels).  
Track income and expenses, get automatic transaction categorization, and view spending forecasts.

## Features

- 🔐 JWT authentication (register / login / logout)
- 💰 Add income & expense transactions
- 🧠 ML‑powered auto‑categorization (Naive Bayes on TF‑IDF)
- 📈 Next‑month spending forecast (time‑series smoothing)
- 📊 Interactive spending pie chart
- 🗂 Budget creation & tracking
- 🐳 Fully containerized with Docker Compose

## Tech Stack

| Layer       | Technology                              |
|-------------|-----------------------------------------|
| Frontend    | Flutter (Android, Web)                  |
| Backend     | Python 3.13, FastAPI, Celery             |
| Database    | PostgreSQL 16                           |
| Cache       | Redis 7                                 |
| AI/ML       | scikit‑learn, statsmodels, pandas        |
| DevOps      | Docker, Docker Compose, Git, GitHub     |

## Quick Start (Docker)

    # Clone the repository
    git clone https://github.com/BonaventureMaina/smartbudget.git
    cd smartbudget

    # Start all services
    docker compose up -d --build

    # Seed default categories
    docker compose exec backend python seed_categories.py

    # API is live at http://localhost:8000
    # Interactive docs at http://localhost:8000/docs

## Run Flutter App

    cd frontend
    flutter run -d chrome   # web
    # or
    flutter run -d android  # Android device/emulator

Make sure the backend is running on `localhost:8000`.

## API Endpoints

| Method | Path                    | Description              |
|--------|-------------------------|--------------------------|
| POST   | `/auth/register`        | Create account           |
| POST   | `/auth/login`           | Obtain JWT token         |
| GET    | `/users/me`             | Current user profile     |
| POST   | `/transactions/`        | Create transaction       |
| GET    | `/transactions/`        | List transactions        |
| GET    | `/transactions/forecast`| Spending forecast         |
| POST   | `/budgets/`             | Create budget            |
| GET    | `/budgets/`             | List budgets             |
| GET    | `/health`               | Health check             |

## Project Structure

    smartbudget/
    ├── backend/
    │   ├── app/
    │   │   ├── main.py
    │   │   ├── database.py
    │   │   ├── models.py
    │   │   ├── schemas.py
    │   │   ├── auth.py
    │   │   ├── ml_service.py
    │   │   └── routers/
    │   ├── Dockerfile
    │   └── requirements.txt
    ├── frontend/
    │   └── lib/
    │       ├── main.dart
    │       ├── config.dart
    │       ├── models/
    │       ├── services/
    │       ├── providers/
    │       └── screens/
    ├── docker-compose.yml
    └── README.md

## Author

**Bonaventure Maina** – full‑stack portfolio project.
