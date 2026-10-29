from pathlib import Path

# Dynamically locate project root (2 levels up from src/config.py -> northwind-capstone-pipeline/)
PROJECT_ROOT = Path(__file__).resolve().parent.parent

# Folder paths
DATA_DIR = PROJECT_ROOT / "data"
RAW_DATA_DIR = DATA_DIR / "raw"
SQL_DIR = PROJECT_ROOT / "sql"
NOTEBOOKS_DIR = PROJECT_ROOT / "notebooks"
REPORTS_DIR = PROJECT_ROOT / "reports"

# Database Configuration Constants
DB_USER = "root"
DB_PASSWORD = "Syune2023!"
DB_HOST = "localhost"
DB_PORT = "3306"

# SQLAlchemy Connection Strings
DATABASE_URL_ROOT = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/"
DATABASE_URL_DW = f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/dw"