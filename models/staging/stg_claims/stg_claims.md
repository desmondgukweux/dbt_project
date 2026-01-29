{% docs stg_claims %}

## Data Model Documentation: stg_claims

### Purpose
This staging model cleans and standardizes raw patient claims, casts all fields to consistent types, and derives a monthly bucket for downstream aggregation and partitioning.

### Caveats
1. Data types are cast from raw sources and may require updates if upstream schemas change.
2. The model does not deduplicate claims; it assumes `claim_id` is unique in the raw source.
3. Incremental runs filter by the latest `claim_date` in the target table with a one‑month lookback.

### Details
- Grain: One row per `claim_id`.
- Additive facts: `claim_amount`.
- Non-additive facts: `patient_id`, `claim_date`, `diagnosis_code`, `claim_month`, `loaded_at`.

### Playbook
1. **Validate claim volume by month**
```sql
select claim_month, count(*) as claim_count
from {{ ref('stg_claims') }}
group by 1
order by 1 desc;
```

2. **Check for missing claim dates**
```sql
select count(*) as missing_dates
from {{ ref('stg_claims') }}
where claim_date is null;
```

3. **Confirm latest claim date ingested**
```sql
select max(claim_date) as latest_claim_date
from {{ ref('stg_claims') }};
```

{% enddocs %}
