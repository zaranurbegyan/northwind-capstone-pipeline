from sqlalchemy import create_engine
from src.config import DATABASE_URL_ROOT, DATABASE_URL_DW

def get_root_engine():
    """Creates and returns a SQLAlchemy engine for root level operations (DDL / schema creation)."""
    return create_engine(DATABASE_URL_ROOT)

def get_dw_engine():
    """Creates and returns a SQLAlchemy engine connected directly to the 'dw' database."""
    return create_engine(DATABASE_URL_DW)

# Pre-instantiated engines for convenience
root_engine = get_root_engine()
dw_engine = get_dw_engine()