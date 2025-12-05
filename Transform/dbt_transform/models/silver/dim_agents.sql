{{ config(
    materialized='incremental',
    unique_key='ID',
    incremental_strategy='merge',
    on_schema_change='ignore',
    schema_hardening='none',
    merge_update_columns=[
        'NAME','EXPERIENCE','STATE','updated_at'
    ],
    CLUSTER_BY = ['AGENT_SK']
) }}

with src as (
    select
        ID,
        NAME,
        upper(EXPERIENCE) as EXPERIENCE,
        upper(STATE) as STATE,
        _AIRBYTE_EXTRACTED_AT as extracted_at
    from {{ source('bronze','AGENTS') }}
),

deduped as (
    select
        *,
        row_number() over (
            partition by ID
            order by extracted_at desc
        ) as rnk
    from src
)

select
    {{ dbt_utils.generate_surrogate_key(['ID']) }} as AGENT_SK,
    ID,
    NAME,
    EXPERIENCE,
    STATE,
    current_timestamp() as created_at,
    current_timestamp() as updated_at
from deduped
where rnk = 1