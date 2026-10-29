from pathlib import Path
from sqlalchemy import text

# Import database connectors and config from src/
from src.db_connector import root_engine
from src.config import SQL_DIR

# Import modular pipeline functions
from src.stage_raw_data import run_staging_ingestion
from src.transform_warehouse import run_warehouse_transformation


def run_sql_file(filepath, engine):
    """Helper to execute multi-statement SQL files cleanly."""
    print(f"Executing SQL file: {filepath.name}...")
    if not filepath.exists():
        raise FileNotFoundError(f"Could not find SQL file at: {filepath}")

    with open(filepath, "r", encoding="utf-8") as f:
        sql_script = f.read()

    statements = [stmt.strip() for stmt in sql_script.split(";") if stmt.strip()]

    with engine.begin() as conn:
        for stmt in statements:
            conn.execute(text(stmt))
    print(f"SUCCESS: {filepath.name} executed successfully.")


def main():
    print("==================================================")
    print("STARTING NORTHWIND DATA WAREHOUSE PIPELINE")
    print("==================================================")

    try:
        # Step 1: Create Database & Staging Schemas (01 and 02)
        print("\n--- Step 1: Setting up Database and Staging Schemas ---")
        run_sql_file(SQL_DIR / "01_create_db_and_schemas.sql", root_engine)
        run_sql_file(SQL_DIR / "02_create_staging.sql", root_engine)

        # Step 2: Ingest Raw CSV Data into Staging
        print("\n--- Step 2: Ingesting Raw CSV Data into Staging ---")
        run_staging_ingestion()

        # Step 3: Create Data Warehouse Star Schema & Tables (03)
        print("\n--- Step 3: Creating Data Warehouse Star Schema ---")
        run_sql_file(SQL_DIR / "03_create_warehouse.sql", root_engine)

        # Step 4: Run Warehouse Transformation (Executes Date Gen, 04, and 05 via transform_warehouse.py)
        print("\n--- Step 4: Executing Warehouse Transformation (04 & 05) ---")
        run_warehouse_transformation()

        print("\n==================================================")
        print("PIPELINE COMPLETED SUCCESSFULLY FROM END TO END!")
        print("==================================================")

    except Exception as e:
        print(f"\nCRITICAL PIPELINE FAILURE: {e}")

    finally:
        root_engine.dispose()


if __name__ == "__main__":
    main()