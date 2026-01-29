{% docs mrt_patient_claims_summary %}

## Data Model Documentation: mrt_patient_claims_summary

### Purpose
This mart model exposes a reporting-friendly patient claims summary for analytics and dashboards. It is optimized for downstream consumption with a consistent, patient-level grain.

### Caveats
1. Metrics are derived from upstream intermediate models and inherit their data quality.
2. Patients without claims will have null date and aggregate fields.
3. Incremental runs filter on `first_claim_date` with a one‑month lookback.

### Details
- Grain: One row per `patient_id`.
- Additive facts: `total_claims`, `total_claim_amount`.
- Non-additive facts: `first_claim_date`, `last_claim_date`, `days_since_first_claim`, `loaded_at`.

### Playbook
1. **Validate most recent claim date**
```sql
select max(last_claim_date) as most_recent_claim
from {{ ref('mrt_patient_claims_summary') }};
```

2. **Top patients by total claim amount**
```sql
select patient_id, total_claim_amount
from {{ ref('mrt_patient_claims_summary') }}
order by total_claim_amount desc
limit 20;
```

3. **Check overall claim volume**
```sql
select sum(total_claims) as total_claims
from {{ ref('mrt_patient_claims_summary') }};
```

{% enddocs %}
