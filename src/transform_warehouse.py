from pathlib import Path
import pandas as pd
from sqlalchemy import text

from .config import SQL_DIR
from .db_connector import dw_engine

# Only 04 and 05 are executed here per your task requirement
PATH_04 = SQL_DIR / "04_upsert_dimensions.sql"
PATH_05 = SQL_DIR / "05_upsert_fact_sales.sql"


def run_sql_file(filepath, engine):
    """Executes multi-statement or single-statement SQL files cleanly."""
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


def generate_dim_date():
    """Generates the calendar date dimension from 1990 to 9999 and populates dw.dim_date."""
    print("Generating dw.dim_date calendar...")
    dates = pd.date_range(start="1990-01-01", end="9999-12-31")

    df_dates = pd.DataFrame({
        "date_id_sk_pk": dates.strftime("%Y%m%d").astype(int),
        "full_date": dates.date,
        "year": dates.year,
        "quarter": dates.quarter,
        "month_number": dates.month,
        "month_name": dates.strftime("%B"),
        "month_short": dates.strftime("%b"),
        "week_number": dates.isocalendar().week.astype(int),
        "day_of_week": dates.day_of_week + 1,
        "day_name": dates.strftime("%A"),
        "is_weekend": dates.day_of_week >= 5,
        "fiscal_year": dates.year,
        "fiscal_quarter": dates.quarter
    })

    df_dates.to_sql("dim_date", con=dw_engine, if_exists="append", index=False)
    print(f"SUCCESS: dw.dim_date populated with {len(df_dates)} rows.")


def run_warehouse_transformation():
    """
    Called by run_pipeline.py.
    Populates dim_date and executes 04 (Dimensions Upsert) & 05 (Fact Upsert).
    """
    try:
        print("\n--- Starting Data Warehouse Transformation Layer ---")

        # Step A: Populate Date Dimension via Python
        generate_dim_date()

        # Step B: Upsert Dimensions via SQL Script (04)
        run_sql_file(PATH_04, dw_engine)

        # Step C: Upsert Fact Sales via SQL Script (05)
        run_sql_file(PATH_05, dw_engine)

        print("\nSUCCESS: Warehouse Transformation (04 & 05) Completed Successfully!")

    except Exception as e:
        print(f"WAREHOUSE TRANSFORMATION FAILED: {e}")
        raise e

    finally:
        dw_engine.dispose()


if __name__ == "__main__":
    run_warehouse_transformation()