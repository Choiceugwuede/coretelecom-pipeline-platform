from pendulum import datetime
from datetime import timedelta
from airflow.providers.standard.operators.python import PythonOperator
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.airbyte.operators.airbyte import AirbyteTriggerSyncOperator
from airflow.sdk import DAG

default_args = {
    "owner": "choice",
    "start_date": datetime(2025, 12, 1),
    "retries": 2,
    "retry_delay": timedelta(minutes=10),
}


with DAG(
    dag_id="complaints_elt_test",
    default_args=default_args,
    schedule=None,
    catchup=False,
    max_active_runs=1,
    max_active_tasks=3
):
    
       # --- Extraction functions wrapped to lazy-import heavy modules ---
    def run_extract_load_customer():
        from customers import _extract_load_customer
        _extract_load_customer()

    def run_extract_load_agent():
        from Agent import _extract_load_agent
        _extract_load_agent()

    def run_extract_load_call_center():
        from call_center import _extract_load_call_center
        _extract_load_call_center()

    def run_extract_load_social_media():
        from social_media import _extract_load_social_media
        _extract_load_social_media()

    def run_extract_load_web_complaints():
        from web_complaints import _extract_load_web_complaints
        _extract_load_web_complaints()

    # Extract and load 
    extract_load_customers = PythonOperator(
        task_id="extract_load_customers",
        python_callable=run_extract_load_customer
    )

    extract_load_agents = PythonOperator(
        task_id="extract_load_agents",
        python_callable=run_extract_load_agent
    )

    extract_load_call_center = PythonOperator(
        task_id="extract_load_call_center",
        python_callable=run_extract_load_call_center
    )

    extract_load_social_media = PythonOperator(
        task_id="extract_load_social_media",
        python_callable=run_extract_load_social_media
    )

    extract_load_web_complaints = PythonOperator(
        task_id="extract_load_web_complaints",
        python_callable=run_extract_load_web_complaints
    )

    #Loading to Snowflakes - Airbyte 
    sync_customers = AirbyteTriggerSyncOperator(
        task_id="airbyte_sync_customers",
        airbyte_conn_id="airbyte_conn",
        connection_id="b2d14567-bc23-41a8-81b0-75f4c15d2b52",
        asynchronous=False,
        timeout=2300,
        wait_seconds=10,
    )

    sync_agents= AirbyteTriggerSyncOperator(
        task_id="airbyte_sync_agents",
        airbyte_conn_id="airbyte_conn",
        connection_id="6f393b3b-b498-41a4-b1c3-8bdc0b711bc5",
        asynchronous=False,
        timeout=2300,
        wait_seconds=10,

    )

    sync_call_logs=AirbyteTriggerSyncOperator(
        task_id="airbyte_sync_call_logs",
        airbyte_conn_id="airbyte_conn",
        connection_id="2e8825fb-ed81-4e28-bac9-e99252b19cd8",
        asynchronous=False,
        timeout=2300,
        wait_seconds=10,
    )

    sync_social_media=AirbyteTriggerSyncOperator(
        task_id="airbyte_social_media",
        airbyte_conn_id="airbyte_conn",
        connection_id="4010d494-3288-402f-866f-8394b7e1a707",
        asynchronous=False,
        timeout=2300,
        wait_seconds=10,
    )

    sync_website_complaints=AirbyteTriggerSyncOperator(
        task_id="airbyte_website_form",
        airbyte_conn_id="airbyte_conn",
        connection_id="d337d6c6-5373-4351-a088-3b726f4ea9c5",
        asynchronous=False,
        timeout=2300,
        wait_seconds=10,
    )

    # DBT Transform - run dims > facts > gold
    DBT_PROJECT_DIR = "/opt/airflow/dbt"
    LOG_DIR = "/opt/airflow/logs/complaints_etl"
    DBT_PROFILES_DIR = "/opt/airflow/.dbt"

    generate_profiles = BashOperator(
        task_id="generate_dbt_profiles",
        bash_command="python3 /opt/airflow/dbt/generate_profiles_yml.py"
    )


    dbt_run_dims = BashOperator(
        task_id="dbt_run_customers_agents",
        bash_command=(
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt deps --profiles-dir {DBT_PROFILES_DIR} && "
            f"dbt run --select path:models/silver/dim* --profiles-dir {DBT_PROFILES_DIR} "
            f"2>&1 | tee {LOG_DIR}/dbt_run_dims.log"
        )
    )

    dbt_run_call_logs = BashOperator(
        task_id="dbt_run_call_logs",
        bash_command = (
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt deps --profiles-dir {DBT_PROFILES_DIR} && "
            f"dbt run --select path:models/silver/call_center --profiles-dir {DBT_PROFILES_DIR} "
            f"2>&1 | tee {LOG_DIR}/dbt_run_call_center.log"

        )
          )
    
    dbt_run_social_media = BashOperator(
        task_id="dbt_run_social_media",
        bash_command = (
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt deps --profiles-dir {DBT_PROFILES_DIR} && "
            f"dbt run --select path:models/silver/social_media --profiles-dir {DBT_PROFILES_DIR} "
            f"2>&1 | tee {LOG_DIR}/dbt_run_social_media.log"

        )
    )

    dbt_run_web_complaints = BashOperator(
        task_id = "dbt_run_web_forms",
        bash_command = (
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt deps --profiles-dir {DBT_PROFILES_DIR} && "
            f"dbt run --select path:models/silver/website_complaints --profiles-dir {DBT_PROFILES_DIR} "
            f"2>&1 | tee {LOG_DIR}/dbt_web_complaints.log"

        )
    )

    dbt_run_complaints = BashOperator(
        task_id="dbt_complaints",
        bash_command = (
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt deps --profiles-dir {DBT_PROFILES_DIR} && "
            f"dbt run --select path:models/gold/complaints --profiles-dir {DBT_PROFILES_DIR} "
            f"2>&1 | tee {LOG_DIR}/dbt_complaints.log"

        )
    )

    dbt_test = BashOperator(
        task_id = "dbt_test",
        bash_command = (
            f"cd {DBT_PROJECT_DIR} && "
            f"dbt deps --profiles-dir {DBT_PROFILES_DIR} && "
            f"dbt test --profiles-dir {DBT_PROFILES_DIR} "
            f"2>&1 | tee {LOG_DIR}/dbt_test.log"

        )
    )

    # --- Extract chain ---
    extract_load_customers >> sync_customers
    extract_load_agents >> sync_agents
    extract_load_call_center >> sync_call_logs
    extract_load_social_media >> sync_social_media
    extract_load_web_complaints >> sync_website_complaints

    # running dbt dims after extraction and sync is complete
    [
        sync_customers,
        sync_agents,
        sync_call_logs,
        sync_social_media,
        sync_website_complaints
    ] >> generate_profiles >> dbt_run_dims

    # --- dbt_run_dims >> fact models ---
    dbt_run_dims >> dbt_run_call_logs
    dbt_run_dims >> dbt_run_social_media
    dbt_run_dims >> dbt_run_web_complaints

    # --- fact models >> complaints fact ---
    dbt_run_call_logs >> dbt_run_complaints
    dbt_run_social_media >> dbt_run_complaints
    dbt_run_web_complaints >> dbt_run_complaints

    # --- complaints fact >> dbt tests ---
    dbt_run_complaints >> dbt_test
