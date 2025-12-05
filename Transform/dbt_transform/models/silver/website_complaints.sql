{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='WEB_SK',
    CLUSTER_BY = ['CUSTOMER_ID', 'WEBFORMGENERATIONDATE', 'AGENT_ID']
) }}


with src as (
    select
        COLUMN1 as WEB_ID,
        AGENT_ID,
        REQUEST_ID,
        CUSTOMER_ID,
        TRY_TO_TIMESTAMP(REQUEST_DATE) as REQUEST_DATE,
        TRY_TO_TIMESTAMP(RESOLUTION_DATE) as RESOLUTION_DATE,
        UPPER(RESOLUTIONSTATUS) as RESOLUTIONSTATUS,
        UPPER(COMPLAINT_CATEGO_RY) as COMPLAINT_CATEGORY,
        TRY_TO_DATE(WEBFORMGENERATIONDATE) AS WEBFORMGENERATIONDATE,
        _AIRBYTE_EXTRACTED_AT as extracted_at
    from {{ source('bronze','WEBSITE_CUSTOMER_COMPLAINTS') }}
    {% if is_incremental() %}
      where _AIRBYTE_EXTRACTED_AT > (select max(extracted_at) from {{ this }})
    {% endif %}
),

agent_lookup as (
    select
        a.ID,
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
    {{ dbt_utils.generate_surrogate_key(['WEB_ID', 'REQUEST_ID']) }} as WEB_SK,  
    WEB_ID,
    a.AGENT_SK as AGENT_ID,
    REQUEST_ID,
    c.CUSTOMER_SK as CUSTOMER_ID,
    REQUEST_DATE,
    RESOLUTION_DATE,
    RESOLUTIONSTATUS,
    COMPLAINT_CATEGORY,
    WEBFORMGENERATIONDATE,
    current_timestamp() as created_at
from src s
left join agent_lookup a on s.AGENT_ID = try_cast(a.ID as integer)
left join customer_lookup c on s.CUSTOMER_ID = c.CUSTOMER_ID)

select * from fact


