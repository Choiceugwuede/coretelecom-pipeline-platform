{{ config(
    materialized='incremental',
    incremental_strategy='append',
    unique_key='SOCIAL_SK',
    CLUSTER_BY = ['CUSTOMER_ID', 'MEDIACOMPLAINTGENERATIONDATE', 'AGENT_ID']
) }}


with src as (
    select
        KEY as SOCIAL_ID,
        AGENT_ID,
        CUSTOMER_ID,
        COMPLAINT_ID,
        TRY_TO_TIMESTAMP(REQUEST_DATE) as REQUEST_DATE,
        UPPER(MEDIA_CHANNEL) AS MEDIA_CHANNEL,
        TRY_TO_TIMESTAMP(RESOLUTION_DATE) as RESOLUTION_DATE,
        UPPER(RESOLUTIONSTATUS) as RESOLUTIONSTATUS,
        UPPER(COMPLAINT_CATEGO_RY) as COMPLAINT_CATEGORY,
        TRY_TO_DATE(MEDIACOMPLAINTGENERATIONDATE) AS MEDIACOMPLAINTGENERATIONDATE,
        _AIRBYTE_EXTRACTED_AT as extracted_at
    from {{ source('bronze','SOCIAL_MEDIA') }}
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
    {{ dbt_utils.generate_surrogate_key(['SOCIAL_ID', 'COMPLAINT_ID']) }} as SOCIAL_SK, 
    SOCIAL_ID,
    a.AGENT_SK as AGENT_ID,
    c.CUSTOMER_SK as CUSTOMER_ID,
    COMPLAINT_ID,
    REQUEST_DATE,
    MEDIA_CHANNEL,
    RESOLUTION_DATE,
    RESOLUTIONSTATUS,
    COMPLAINT_CATEGORY,
    MEDIACOMPLAINTGENERATIONDATE,
    current_timestamp() as created_at
from src s
left join agent_lookup a on s.AGENT_ID = try_cast(a.ID as integer)
left join customer_lookup c on s.CUSTOMER_ID = c.CUSTOMER_ID)

select * from fact


