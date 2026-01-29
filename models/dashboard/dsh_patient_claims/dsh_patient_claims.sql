{{ config(
    materialized='view',
    tags=['dashboard_tables','daily','claims']
) }}

select
    patient_id,
    first_claim_date,
    last_claim_date,
    total_claims,
    total_claim_amount,
    days_since_first_claim,
    current_timestamp() as loaded_at
from {{ ref('mrt_patient_claims_summary') }}
