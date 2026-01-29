
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='claim_id',
    on_schema_change='sync_all_columns',
    tags=['staging_tables','daily','claims']
) }}

-- Working example: staging model for raw patient claims
-- Cleans data and derives claim_month


with source as (
    select * from {{ ref('raw_claims') }}
    where
        true
    {% if is_incremental() %}
    and 
        cast(claim_date as date) >= (select dateadd(month, -1, max(claim_date)) from {{ this }})
    {% endif %}
),
renamed as (
    select
        cast(claim_id as string) as claim_id,
        cast(patient_id as string) as patient_id,
        cast(claim_date as date) as claim_date,
        cast(claim_amount as numeric) as claim_amount,
        cast(diagnosis_code as string) as diagnosis_code,
        DATE_TRUNC(cast(claim_date as date), MONTH) as claim_month,
        current_timestamp() as loaded_at

    from source
)
select * from renamed
