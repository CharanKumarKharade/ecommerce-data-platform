
FROM apache/airflow:3.1.5

COPY docker/airflow/requirements.txt /requirements.txt

RUN pip install --no-cache-dir \
    "apache-airflow==3.1.5" \
    -r /requirements.txt
