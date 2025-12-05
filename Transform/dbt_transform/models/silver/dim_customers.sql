{{ config(
    materialized='incremental',
    unique_key='CUSTOMER_ID',
    incremental_strategy='merge',
    on_schema_change='ignore',
    schema_hardening='none',
    merge_update_columns=[
        'NAME','EMAIL','GENDER','ADDRESS','DATE_OF_BIRTH','SIGNUP_DATE','updated_at'
    ],
    cluster_by=['CUSTOMER_SK']
) }}

with src as (
    select
        CUSTOMER_ID,
        NAME,
        EMAIL,
        upper(GENDER) as GENDER,
        ADDRESS,
        try_to_date(DATE_OF_BIRTH) as DATE_OF_BIRTH,
        try_to_date(SIGNUP_DATE) as SIGNUP_DATE,
        _AIRBYTE_EXTRACTED_AT as extracted_at
    from {{ source('bronze','CUSTOMERS') }}
),

deduped as (
    select
        *,
        row_number() over (
            partition by CUSTOMER_ID
            order by extracted_at desc
        ) as rnk
    from src
)

select
    {{ dbt_utils.generate_surrogate_key(['CUSTOMER_ID']) }} as CUSTOMER_SK,
    CUSTOMER_ID,
    NAME,
    EMAIL,
    GENDER,
    ADDRESS,
    DATE_OF_BIRTH,
    SIGNUP_DATE,
    current_timestamp() as created_at,
    current_timestamp() as updated_at
from deduped
where rnk = 1