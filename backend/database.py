from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import Base

# Database URL - SQLite for now, easy to change later
SQLALCHEMY_DATABASE_URL = "sqlite:///./maboutique.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, 
    connect_args={"check_same_thread": False}  # Only needed for SQLite
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Create all tables
def create_tables():
    Base.metadata.create_all(bind=engine)

# Dependency to get DB session
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()