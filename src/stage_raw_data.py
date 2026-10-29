import pandas as pd
from pathlib import Path

# Direct imports from sibling files in the src/ folder
from .config import RAW_DATA_DIR
from .db_connector import root_engine

# List of the 11 Northwind tables
tables = [
    "categories",
    "customers",
    "employees",
    "employee_territories",
    "order_details",
    "orders",
    "products",
    "regions",
    "shippers",
    "suppliers",
    "territories",
]


def run_staging_ingestion():
    """
    Reads local raw CSV files from data/raw/ and loads them 1:1 into the stg schema.
    Called as Step 2 by run_pipeline.py.
    """
    print("\n--- Starting Raw Data Staging Ingestion ---")

    try:
        for table_name in tables:
            # Check for both naming conventions (e.g., raw_categories.csv or categories.csv)
            file_names_to_try = [f"raw_{table_name}.csv", f"{table_name}.csv"]
            file_path = None

            for fname in file_names_to_try:
                candidate = RAW_DATA_DIR / fname
                if candidate.exists():
                    file_path = candidate
                    break

            if not file_path or not file_path.exists():
                print(f"WARNING: Raw CSV file for '{table_name}' not found in {RAW_DATA_DIR}. Skipping...")
                continue

            print(f"Reading {file_path.name}...")
            df = pd.read_csv(file_path)

            # Drop completely empty rows if any trailing newlines exist
            df = df.dropna(how="all")

            # Insert raw data into the pre-created staging table in the 'stg' schema
            df.to_sql(
                name=table_name,
                con=root_engine,
                schema="stg",
                if_exists="append",
                index=False
            )

            print(f"SUCCESS: Loaded stg.{table_name} | {len(df)} rows and {len(df.columns)} columns")

        print("SUCCESS: Staging ingestion completed successfully!")

    except Exception as e:
        print(f"STAGING INGESTION FAILED: {e}")
        raise e


if __name__ == "__main__":
    # Allows you to still test this script independently if desired
    run_staging_ingestion()