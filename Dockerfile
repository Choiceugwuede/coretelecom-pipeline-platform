FROM apache/airflow:3.1.0-python3.11

ENV PYTHONPATH=/opt/airflow/scripts
ENV AIRFLOW_HOME=/opt/airflow

# Install Python requirements 

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# Copy Airflow project files
COPY airflow/dags/ /opt/airflow/dags/
COPY airflow/plugins/ /opt/airflow/plugins/
COPY airflow/config/ /opt/airflow/config/

# Copy ETL scripts
COPY Extraction_Loading/ /opt/airflow/scripts/

# Copy DBT 
COPY Transform/dbt_transform/ /opt/airflow/dbt/

# Ensure logs folder exists
USER root
RUN mkdir -p /opt/airflow/logs/complaints_etl \
    && chown -R airflow: /opt/airflow
USER airflow
