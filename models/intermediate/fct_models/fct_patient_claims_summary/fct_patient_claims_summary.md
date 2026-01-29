{% docs fct_patient_claims_summary %}

## Data Model Documentation: fct_patient_claims_summary

### Purpose
This fact model summarizes claim activity per patient by combining claim aggregates with patient attributes. It is intended to support intermediate-level analysis and serve as a source for marts.

### Caveats
1. Aggregations are derived from `stg_claims` and inherit its data quality.
2. Patients without claims will have null aggregate fields.
3. Incremental runs filter on `first_claim_date` with a one‑month lookback.

### Details
- Grain: One row per `patient_id`.
- Additive facts: `total_claims`, `total_claim_amount`.
- Non-additive facts: `first_claim_date`, `last_claim_date`, `days_since_first_claim`, `loaded_at`.

### Playbook
1. **Validate last claim recency**
```sql
select max(last_claim_date) as most_recent_claim
from {{ ref('fct_patient_claims_summary') }};
```

2. **Top patients by total claim amount**
```sql
select patient_id, total_claim_amount
from {{ ref('fct_patient_claims_summary') }}
order by total_claim_amount desc
limit 20;
```

3. **Check claim count distribution**
```sql
select total_claims, count(*) as num_patients
from {{ ref('fct_patient_claims_summary') }}
group by 1
order by 1 desc;
```

{% enddocs %}
