--

{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='patient_id',
    on_schema_change='sync_all_columns',
    tags=['intermediate_tables','daily','patients']
) }}

-- PART 1
-- TASK: Create a dimension model for patients
-- Reference raw_patients and stg_claims
-- Enrich patients with:
--   - First claim date
--   - Total number of claims
--   - Total claim amount
--   - Days since first claim


with patients as (
    select * from {{ ref('raw_patients') }}
),

claims as (
    select *
    from {{ ref('stg_claims') }}
),

aggregated_claims as (
    select
        patient_id,
        min(claim_date) as first_claim_date,
        count(*) as total_claims,
        sum(claim_amount) as total_claim_amount,
        date_diff(current_date(), min(claim_date), day) as days_since_first_claim
    from claims
    group by patient_id
),

final as (
    select
        p.*,
        ac.first_claim_date,
        ac.total_claims,
        ac.total_claim_amount,
        ac.days_since_first_claim,
        current_timestamp() as loaded_at
    from patients p
    left join aggregated_claims ac
        on p.patient_id = ac.patient_id
    {% if is_incremental() %}
    where
        ac.first_claim_date is not null
        and {{ apply_incremental_filter('first_claim_date') }}
    {% endif %}
)

select * from final
