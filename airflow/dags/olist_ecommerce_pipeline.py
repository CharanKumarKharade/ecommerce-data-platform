
from datetime import datetime, timedelta

from airflow import DAG
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator


# Project configuration
DBT_PROJECT_DIR = "/opt/airflow/transform/ecommerce_analytics"
DBT_PROFILES_DIR = "/opt/airflow/config/dbt"

default_args = {
    "owner": "data-engineering",
    "retries": 2,
    "retry_delay": timedelta(minutes=2),
}


with DAG(
    dag_id="olist_ecommerce_pipeline",
    description="End-to-end Olist e-commerce data engineering pipeline",
    default_args=default_args,
    start_date=datetime(2026, 11, 26),
    schedule=None,
    catchup=False,
    tags=["olist", "postgres", "dbt", "data-engineering"],
) as dag:

    ingest_raw_data = BashOperator(
        task_id="ingest_raw_data",
        bash_command="python /opt/airflow/ingestion/load_data.py",
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            f"dbt run --project-dir {DBT_PROJECT_DIR} "
            f"--profiles-dir {DBT_PROFILES_DIR} "
            "--target airflow"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            f"dbt test --project-dir {DBT_PROJECT_DIR} "
            f"--profiles-dir {DBT_PROFILES_DIR} "
            "--target airflow"
        ),
    )

    ingest_raw_data >> dbt_run >> dbt_test
