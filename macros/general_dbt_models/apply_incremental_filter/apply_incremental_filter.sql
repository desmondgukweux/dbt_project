{% macro apply_incremental_filter(time_column, target_table=this, default_start_date=var('default_start_date')) %}

    {% set lookback_days = var('default_lookback_days', 0) %}

    {% if is_incremental() %}
        -- Running in incremental mode: calculate the maximum modified time with a lookback period
        {% set sql %}
            select max({{ time_column }}) - interval '{{ lookback_days }} day' from {{ target_table }}
        {% endset %}

        -- Run the SQL and retrieve the result
        {% set last_modified_time = run_query(sql).columns[0].values()[0] %}
        {{ time_column }} > '{{ last_modified_time }}'::timestamp_ntz

    {% else %}
        -- Full refresh mode: use default start date
        {{ time_column }} > '{{ default_start_date }}'::timestamp_ntz
    {% endif %}

{% endmacro %}
