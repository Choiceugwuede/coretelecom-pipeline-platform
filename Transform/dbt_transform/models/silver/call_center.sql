{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='CALL_SK',
    cluster_by = ['CUSTOMER_ID', 'CALLLOGSGENERATIONDATE', 'AGENT_ID']
) }}


with src as (
    select
        "UNNAMED:_0" as log_key,
        CALL_ID,
        AGENT_ID,
        CUSTOMER_ID,
        TRY_TO_TIMESTAMP(CALL_START_TIME) as CALL_START_TIME,
        TRY_TO_TIMESTAMP(CALL_END_TIME) as CALL_END_TIME,
        UPPER(RESOLUTIONSTATUS) as RESOLUTIONSTATUS,
        UPPER(COMPLAINT_CATEGO_RY) as COMPLAINT_CATEGORY,
        TRY_TO_DATE(CALLLOGSGENERATIONDATE) AS CALLLOGSGENERATIONDATE,
        _AIRBYTE_EXTRACTED_AT as extracted_at
    from {{ source('bronze','CALL_CENTER') }}
    {% if is_incremental() %}
      where _AIRBYTE_EXTRACTED_AT > (select max(extracted_at) from {{ this }})
    {% endif %}
),

agent_lookup as (
    select
        a.ID ,
        a.AGENT_SK
    from {{ ref('dim_agents') }} a
),

customer_lookup as (
    select
        c.CUSTOMER_ID ,
        c.CUSTOMER_SK
    from {{ ref('dim_customers') }} c
),

fact as (select
    {{ dbt_utils.generate_surrogate_key(['log_key', 'CALL_ID']) }}  as CALL_SK,
    log_key,
    CALL_ID,
    a.AGENT_SK as AGENT_ID,
    c.CUSTOMER_SK as CUSTOMER_ID,
    CALL_START_TIME,
    CALL_END_TIME,
    RESOLUTIONSTATUS,
    COMPLAINT_CATEGORY,
    CALLLOGSGENERATIONDATE,
    current_timestamp() as created_at
from src s
left join agent_lookup a on s.AGENT_ID = try_cast(a.ID as integer)
left join customer_lookup c on s.CUSTOMER_ID = c.CUSTOMER_ID)

select * from fact


