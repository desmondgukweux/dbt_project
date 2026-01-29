
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='patient_id',
    on_schema_change='sync_all_columns',
    tags=['intermediate_tables','daily','claims']
) }}

with claims as (
    select distinct
        claim_id,
        patient_id,
        claim_date,
        claim_amount,
        diagnosis_code,
        claim_month
    from {{ ref('stg_claims') }}
),

claims_aggregated as (
    select
        patient_id,
        count(*) as total_claims,
        sum(claim_amount) as total_claim_amount,
        min(claim_date) as first_claim_date,
        max(claim_date) as last_claim_date
    from claims
    group by patient_id
),

final as (
    select
        p.patient_id,
        p.first_claim_date,
        p.total_claims,
        p.total_claim_amount,
        c.last_claim_date,
        p.days_since_first_claim,
        current_timestamp() as loaded_at
    from {{ ref('dim_patients') }} p
    left join claims_aggregated c
        on p.patient_id = c.patient_id
    {% if is_incremental() %}
    where
        p.first_claim_date is not null
        and {{ apply_incremental_filter('first_claim_date') }}
    {% endif %}
)

select * from final
