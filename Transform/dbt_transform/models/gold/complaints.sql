{{config(
    materialized = 'incremental',
    incremental_strategy = 'append',
    unique_key = 'COMPLAINT_SK',
    cluster_by = ['CUSTOMER_ID', 'AGENT_ID', 'COMPLAINT_CATEGORY', 'TBL_DT']   
)}}

with call_center as (
    select CALL_SK as COMPLAINT_ID,
    AGENT_ID,
    CUSTOMER_ID,
    RESOLUTIONSTATUS, 
    CALL_START_TIME AS  REQUEST_DATE,
    CASE WHEN RESOLUTIONSTATUS = 'RESOLVED' THEN CALL_START_TIME
    ELSE null
    END AS RESOLUTION_DATE,
    NULL AS MEDIA_CHANNEL,
    COMPLAINT_CATEGORY,
    CALLLOGSGENERATIONDATE AS  COMPLAINTGENERATIONDATE,
    'CALL_CENTER' COMPLAINT_SOURCE,
    CREATED_AT
    from {{ ref('call_center') }}
),


SOCIAL_MEDIA AS (
    SELECT SOCIAL_SK AS COMPLAINT_ID,
    AGENT_ID,
    CUSTOMER_ID,
    RESOLUTIONSTATUS,
    REQUEST_DATE,
    RESOLUTION_DATE,
    MEDIA_CHANNEL,
    COMPLAINT_CATEGORY,
    MEDIACOMPLAINTGENERATIONDATE AS COMPLAINTGENERATIONDATE,
    'SOCIAL_MEDIA' as COMPLAINT_SOURCE,
    CREATED_AT

    FROM  {{ ref('social_media') }}

),

website_complaints as (
    SELECT WEB_SK AS COMPLAINT_ID,
    AGENT_ID,
    CUSTOMER_ID,
    RESOLUTIONSTATUS,
    REQUEST_DATE,
    RESOLUTION_DATE,
    NULL AS MEDIA_CHANNEL,
    COMPLAINT_CATEGORY,
    WEBFORMGENERATIONDATE AS COMPLAINTGENERATIONDATE,
    'WEBSITE_COMPLAINTS' AS COMPLAINT_SOURCE,
    CREATED_AT


    FROM  {{ ref('website_complaints') }}

),

combined as (
    select * from call_center
    union all
    select * from social_media
    union all
    select * from website_complaints
)


select 
     {{ dbt_utils.generate_surrogate_key(['COMPLAINT_ID', 'COMPLAINT_SOURCE']) }} as COMPLAINT_SK, 
    COMPLAINT_ID,
    AGENT_ID,
    CUSTOMER_ID,
    RESOLUTIONSTATUS,
    REQUEST_DATE,
    RESOLUTION_DATE,
    coalesce(MEDIA_CHANNEL, 'Not Applicable') as MEDIA_CHANNEL,
    COMPLAINT_CATEGORY,
    COMPLAINTGENERATIONDATE,
    COMPLAINT_SOURCE,
    CREATED_AT,
    current_date() as TBL_DT

    from combined
    

{% if is_incremental() %}
  where CREATED_AT > (select max(CREATED_AT) from {{ this }})
{% endif %}


