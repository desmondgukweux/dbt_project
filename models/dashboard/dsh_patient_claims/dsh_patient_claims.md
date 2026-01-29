{% docs dsh_patient_claims %}

## Data Model Documentation: dsh_patient_claims

### Purpose
Dashboard-ready patient claims summary sourced from the marts layer for BI consumption.

### Caveats
1. This model is a thin view on top of the mart and does not add new logic.
2. Any upstream changes in the mart will be reflected here automatically.

### Details
- Grain: One row per `patient_id`.
- Additive facts: `total_claims`, `total_claim_amount`.
- Non-additive facts: `first_claim_date`, `last_claim_date`, `days_since_first_claim`, `loaded_at`.

### Playbook
1. **Validate row counts**
```sql
select count(*) as row_count
from {{ ref('dsh_patient_claims') }};
```

2. **Check latest load time**
```sql
select max(loaded_at) as latest_loaded_at
from {{ ref('dsh_patient_claims') }};
```

{% enddocs %}
