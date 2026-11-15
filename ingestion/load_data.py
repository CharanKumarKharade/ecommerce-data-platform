
"""
Olist E-Commerce Data Ingestion Pipeline

Purpose:
    Read Olist CSV files from the local data/raw directory
    and load them into PostgreSQL under the raw schema.

Technologies:
    - Python
    - Pandas
    - SQLAlchemy
    - PostgreSQL
    - python-dotenv
"""

import os
import sys
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL


# ============================================================
# 1. PROJECT CONFIGURATION
# ============================================================

PROJECT_ROOT = Path(__file__).resolve().parents[1]

RAW_DATA_DIR = PROJECT_ROOT / "data" / "raw"

ENV_FILE = PROJECT_ROOT / ".env"

load_dotenv(ENV_FILE)


# ============================================================
# 2. DATABASE CONFIGURATION
# ============================================================

DB_USER = os.getenv("POSTGRES_USER")
DB_PASSWORD = os.getenv("POSTGRES_PASSWORD")
DB_HOST = os.getenv("POSTGRES_HOST", "localhost")
DB_PORT = os.getenv("POSTGRES_PORT", "5432")
DB_NAME = os.getenv("POSTGRES_DB")


# Validate environment variables

required_variables = {
    "POSTGRES_USER": DB_USER,
    "POSTGRES_PASSWORD": DB_PASSWORD,
    "POSTGRES_DB": DB_NAME,
}

missing_variables = [
    key
    for key, value in required_variables.items()
    if not value
]

if missing_variables:
    raise ValueError(
        f"Missing environment variables: {missing_variables}"
    )


# Create database URL safely.
# URL.create handles special characters in passwords.

DATABASE_URL = URL.create(
    drivername="postgresql+psycopg2",
    username=DB_USER,
    password=DB_PASSWORD,
    host=DB_HOST,
    port=int(DB_PORT),
    database=DB_NAME,
)


# Create SQLAlchemy engine

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)


# ============================================================
# 3. SOURCE FILE CONFIGURATION
# ============================================================

CSV_TABLES = {
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_sellers_dataset.csv": "sellers",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "product_category_translation",
}


# ============================================================
# 4. DATABASE CONNECTION VALIDATION
# ============================================================

def test_database_connection():
    """
    Verify that PostgreSQL is reachable before ingestion.
    """

    print("\nTesting PostgreSQL connection...")

    try:
        with engine.connect() as connection:
            result = connection.execute(
                text("SELECT current_database(), current_user")
            )

            database, user = result.fetchone()

            print("Database connection successful!")
            print(f"Database: {database}")
            print(f"User: {user}")

    except Exception as error:
        print(f"Database connection failed: {error}")
        sys.exit(1)


# ============================================================
# 5. CREATE RAW SCHEMA
# ============================================================

def create_raw_schema():
    """
    Create raw schema if it does not already exist.
    """

    print("\nChecking raw schema...")

    with engine.begin() as connection:
        connection.execute(
            text("CREATE SCHEMA IF NOT EXISTS raw")
        )

    print("Raw schema is ready.")


# ============================================================
# 6. CSV INGESTION FUNCTION
# ============================================================

def ingest_csv(file_name: str, table_name: str):
    """
    Read one CSV file and load it into PostgreSQL.

    Parameters:
        file_name: CSV filename
        table_name: Destination PostgreSQL table
    """

    file_path = RAW_DATA_DIR / file_name

    print("\n" + "=" * 60)
    print(f"Processing: {file_name}")
    print("=" * 60)

    # Check whether the source file exists.

    if not file_path.exists():
        raise FileNotFoundError(
            f"Source file not found: {file_path}"
        )

    # Read CSV file.

    df = pd.read_csv(file_path)

    row_count = len(df)
    column_count = len(df.columns)

    print(f"Rows detected: {row_count:,}")
    print(f"Columns detected: {column_count}")

    # Load data into PostgreSQL.

    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists="replace",
        index=False,
        chunksize=5000,
        method="multi",
    )

    print(f"Successfully loaded: raw.{table_name}")
    print(f"Rows inserted: {row_count:,}")


# ============================================================
# 7. RUN COMPLETE INGESTION PIPELINE
# ============================================================

def main():
    """
    Execute ingestion for all configured CSV files.
    """

    print("\n" + "#" * 60)
    print("OLIST E-COMMERCE DATA INGESTION")
    print("#" * 60)

    successful_tables = []
    failed_tables = []

    # Validate database connection.

    test_database_connection()

    # Ensure raw schema exists.

    create_raw_schema()

    # Process each CSV file.

    for file_name, table_name in CSV_TABLES.items():

        try:
            ingest_csv(file_name, table_name)
            successful_tables.append(table_name)

        except Exception as error:
            failed_tables.append(
                {
                    "table": table_name,
                    "error": str(error),
                }
            )

            print(f"FAILED: {table_name}")
            print(f"Reason: {error}")

    # Print ingestion summary.

    print("\n" + "#" * 60)
    print("INGESTION SUMMARY")
    print("#" * 60)

    print(f"Total files: {len(CSV_TABLES)}")
    print(f"Successful: {len(successful_tables)}")
    print(f"Failed: {len(failed_tables)}")

    if successful_tables:
        print("\nSuccessfully loaded tables:")

        for table in successful_tables:
            print(f"  - raw.{table}")

    if failed_tables:
        print("\nFailed tables:")

        for item in failed_tables:
            print(f"  - {item['table']}: {item['error']}")

        sys.exit(1)

    print("\nAll CSV files successfully ingested!")


# ============================================================
# 8. SCRIPT ENTRY POINT
# ============================================================

if __name__ == "__main__":

    try:
        main()

    finally:
        engine.dispose()
