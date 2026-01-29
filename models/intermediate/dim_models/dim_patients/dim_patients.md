{% docs dim_patients %}

## Data Model Documentation: dim_patients

### Purpose
This dimension model enriches patients with claim history metrics including first claim date, total claims, total spend, and days since first claim. It is designed to be a single patient-level lookup for downstream facts and marts.

### Caveats
1. Patients without claims will have null claim metrics.
2. Days since first claim is calculated relative to `current_date()`.
3. Incremental runs filter on `first_claim_date` with a one‑month lookback.

### Details
- Grain: One row per `patient_id`.
- Additive facts: `total_claim_amount`, `total_claims`.
- Non-additive facts: `first_claim_date`, `days_since_first_claim`, `loaded_at`.

### Playbook
1. **Find patients with no claims**
```sql
select count(*) as patients_without_claims
from {{ ref('dim_patients') }}
where first_claim_date is null;
```

2. **Check claim totals distribution**
```sql
select total_claims, count(*) as num_patients
from {{ ref('dim_patients') }}
group by 1
order by 1 desc;
```

3. **Validate most recent first-claim date**
```sql
select max(first_claim_date) as latest_first_claim
from {{ ref('dim_patients') }};
```

{% enddocs %}
