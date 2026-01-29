{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='patient_id',
    on_schema_change='sync_all_columns',
    tags=['mart_tables','daily','claims']
) }}

with base as (
    select *
    from {{ ref('fct_patient_claims_summary') }}
)

select
    patient_id,
    first_claim_date,
    last_claim_date,
    total_claims,
    total_claim_amount,
    days_since_first_claim,
    current_timestamp() as loaded_at
from base
{% if is_incremental() %}
where
    first_claim_date is not null
    and {{ apply_incremental_filter('first_claim_date') }}
{% endif %}
