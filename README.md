## Overview
Welcome to the repository for health_analytics_assessment, our dbt project for managing data transformations and modeling. This README provides a detailed overview of our project architecture, naming conventions, and style guides.

## Table of Contents
- [Project Architecture](#project-architecture)
- [Naming Conventions](#naming-conventions)
- [Style Guide](#style-guide)
- [Getting Started](#getting-started)
- [Contributing](#contributing)

## Project Architecture
Our dbt project is structured into four distinct layers to streamline development and ensure clarity across our transformations. Each layer serves a specific purpose in the processing of data from raw ingestion to analytical reporting.

### Staging Layer (`stg`)
The staging layer serves as the entry point for raw data into our transformation pipeline. Here, raw data is cleaned, tested, and prepared for further transformation. Each source table has a corresponding staging model prefixed with `stg_`, which performs preliminary transformations like field renaming, data type casting, and initial data quality checks. Strucute of the table should be source-alinged. No joins nor business logic should be applied here.

### Intermediate Layer (`int`)
In the intermediate layer, data from the staging models is transformed further into consolidated and optimized datasets (dimentions and facts). These models typically involve more complex business logic, aggregations, and data integration from various sources. This layer acts as a bridge between staging and our analytical marts, ensuring that all data feeding into the marts is accurate, optimized, and business-ready.

### Marts Layer (`marts`)
The final layer in our dbt project is the marts layer. This layer contains data models that are directly used for reporting and analytics. Models in this layer are designed to be query-efficient and are tailored to the specific needs of different business units or reports. Each model typically starts with a prefix that indicates its primary business function, such as `finance_`, `sales_`, etc.

### Dashboard Layer (`dashboard`)
The dashboard layer contains models built specifically for BI tools and reporting dashboards. These models are typically thin views on top of mart models and are optimized for ease of use by analysts and stakeholders.

## Naming Conventions

### General Principles
- **Lowercase Letters:** Use lowercase for all object names to ensure consistency.
- **Underscore Separation:** Use underscores (_) to separate words within names.
- **Short Yet Descriptive:** Names should be short but descriptive enough to convey the purpose or content of the object.

### Tables and Views
- **Prefix with Model Type:** Reflect the model type in the filename, e.g., `stg_`, `dim_`, `fct_`, followed by the model's purpose, e.g., `stg_orders.sql`, `dim_customers.sql`, `fct_sales.sql`.
- **Source Tables:** Use `src_` for source tables, followed by the source name and table purpose, e.g., `src_sales_transactions`.
- **Staging Tables:** Prefix with `stg_`, indicating a staging table, e.g., `stg_customer_details`.
- **Dimension Tables:** Use `dim_` for dimension tables, e.g., `dim_product`.
- **Fact Tables:** Use `fct_` for fact tables, e.g., `fct_sales`.
- **Intermediate Tables:** Use `int_` for tables used in intermediate transformations, e.g., `int_monthly_claims`.
- **Mart Tables:** Use `mrt_` for mart tables, e.g., `mrt_claims`.
- **Aggregation Tables:** Use `agg_` for tables that are aggregating certain metrics, e.g., `agg_weekly_online_login_activity`.
- **Views:** Prefix with `vw_` for views, followed by descriptive names, e.g., `vw_customer_overview`.
- **Dashboards:** Prefix with `dsh_department_dashboard_name` for models connected to Tableau dashboards in certain usecases or requirement for specific stakeholders , e.g., `dsh_finance_licensing` for licensing team.

### Columns
- SQL keywords should not be used as column names.
- **Identifiers:** 
    - Use `_id` suffix for identifiers, e.g., `customer_id`.
    - **Surrogate key:** Each model should have a unique identifier per row that matches the model's grain. To create your unique identifier as a surrogate key as a combindation of columns from your model, please use this dbt function and structure: {{ dbt_utils.generate_surrogate_key(['column_name_1', 'column_name_2', '...']) }}. Each surrogate key should have a standardized name consisting of model_name + suffix `_id`, (e.g. for table `int_bc_customer` the surrogate key is called `int_bc_customer_id`)
- **Boolean Columns:** 
    - Use `is_` or `has_` for booleans, e.g., `is_active`.
- **Aggregate Functions:** Use prefixes that describe the function:
    - Sum: `total_`, e.g., `total_amount`.
    - Count: `num_`, e.g., `num_records`.
    - Average: `avg_`, e.g., `avg_price`.
    - Maximum: `max_`, e.g., `max_value`.
    - Minimum: `min_`, e.g., `min_quantity`.
- **Dates and Times:**
    - timestamps: end with `_at`
    - dates end with `_date`
    - timezones:
        - **Assume UTC by Default**: A common practice is to store all timestamps in UTC to avoid ambiguity. In this case, you can still use the `_at` suffix without additional timezone notation, but ensure it's clearly documented that all timestamps are in UTC in column description. For example, `created_at` implies `created_at_utc` by default.
        - **Explicit Timezone Columns**: For models needing explicit timezone handling without altering the `_at` naming, consider adding separate columns to store timezone information. For example, `created_at` for the timestamp and `created_at_timezone` for the timezone. If timezones differ withing the same process, use suffix  `_ltz` and add separate column specifying which timezone that is. For example `created_at` for the timestamp in UTC and `created_at_ltz` for the timestamp in local timezone and `customer_timezone` for the timezone information (EST, PST, etc).
- **Currencies**: Use `_eur` suffix to denote that the monetary value is in the company currency "EURO" and `_lc` suffix to denote that the monetary value is in the local currency of the market (eur, gdp, usd).
- **Data Type Casting Guidelines**:
Proper data type casting ensures consistency and accuracy across all transformations. Here are our recommendations:
    - **Continuous Data (Decimal Numbers):** 
        Use `number(38,6)` to cast decimal numbers such as sales amounts. This is a Snowflake-recommended practice for precision and scale.
        Example: `sales_amount::number(38,6)`
    - **Discrete Data (Integer Values):** 
        Use `int` for non-decimal numbers such as quantities
        Example: `sales_quantity::int`
    - **Categorical Data (Text/Strings):**
        Use `string` or `varchar` for categorical data, such as names or labels. To maintain consistency within our team, prefer `string` 
        Example: `customer_name::string`
    - **Temporal Data (Timestamps and Dates):**
        ***Timestamps:***
        Use `timestamp`, if needed choose between `timestamp_ltz` (Local Time Zone) and `timestamp_tz` (Time Zone) based on the requirement
        Example: `report_date::timestamp`
        ***Dates:***
        Use `date` for date-only values, which outputs in the `YYYY-MM-DD` format.
        Example: `report_date::date`
    - **Binary Data (Boolean Flags):**
        Use `boolean` for binary flags, ensuring TRUE and FALSE values instead of 0 and 1
        This aligns with dbt's general styling and Snowflake's boolean data type which promotes readability. 
        Example: `is_active::boolean`
        (`is_active = true` is more readable, clean and clear than `is_active = 1`)

### Tags
Tags in model config help us **identify related models** and **define their execution frequency**. Each model should have at least **three tags**:
- **`layer`**: Defines the model's placement in the transformation process.
  - Possible values: `staging_tables`, `intermediate_tables`, `mart_tables`, `dashboard_tables`.
- **`cadence`**: Specifies how often the model should be executed.
  - Possible values: `quadri_hourly`, `daily`, `weekly`, `monthly` (e.g., should the model run **every 4 hours,once a day, twice a week, or once a month**?).
- **`source`**: Represents the **data source** the model depends on.

### Source Freshness
Source freshness help us identify stale sources before stakeholders find out. Adding source freshness checks on source data helps us achieve this.
- **Why This Matters?**
	- Early Detection: Helps teams identify data freshness issues before they impact reporting.
	- Proactive Alerts: Triggers warnings and errors based on data timeliness.
	- Reliable Data: Ensures stakeholders work with the most up-to-date information.
- **Here is an example of how to add source freshness in the source folder:**
  ```yaml
    version: 2

    sources:
        - name: analytics
            description: "Data warehouse schema"
            database: raw
            schema: analytics

            tables:
            - name: orders
                freshness:
                    warn_after: {count: 12, period: hour}  # Warn if data is older than 12 hours
                    error_after: {count: 24, period: hour} # Error if data is older than 24 hours
                loaded_at_field: "created_at"
  ```

## File Naming for dbt Models
- Name all types the files related to a specific model with the model name, and put them into the folder of the same name:
    - **fct_playback_session** (the folder):
        - `fct_claims.md`
        - `fct_claims.sql`
        - `fct_claims.yml`

## Style Guide
To ensure consistency and maintain high-quality code, we format all SQL code that goes into production based on a unified set of rules. We use SQLFluff and adhere to DBT standards to automate and enforce these guidelines.

### Basics
- **Automatic Linting:** DBT Cloud users can use the built-in SQLFluff Cloud IDE integration for automatic linting and formatting ([read more](https://docs.getdbt.com/docs/cloud/dbt-cloud-ide/lint-format)).
- **Case Sensitivity:** Write field names, keywords, and function names in **lowercase**.
- **Formatting:** Use **trailing commas** and four spaces for indentation. Avoid unnecessary empty lines.
- **Line Length:** Keep SQL lines to a maximum of 180 characters.
- **Aliases:** Explicitly use the `as` keyword when aliasing fields or tables.

### Fields, Aggregations, and Grouping
- **Field Placement:** Place fields before aggregates and window functions.
- **Early Aggregation:** Perform aggregations as early as possible to improve performance before joining with other tables.
- **Grouping and Ordering:** Use numbers for ordering and grouping (e.g., `GROUP BY 1, 2`) instead of column names.
- **Columns order:** Organizing columns in a table should follow logical and consistent patterns to enhance readability and maintainability:
    1. Identifiers (Primary Keys, Foreign Keys)
    2. Attributes (Dimensions)
    3. Measures (Facts)
    4. Metadata (source, loadtime_ts)

### Joins
- **Union Preference:** Prefer `UNION ALL` over `UNION` unless duplicates need to be removed.
- **Column Prefixes:** When joining tables, prefix column names with the table alias. This is not necessary if selecting from a single table.
- **Explicit Join Types:** Always specify the join type (e.g., use `INNER JOIN` instead of just `JOIN`).
- **Aliases:** When aliasing the tables, use the first letters of the table name, instead of generic (e.g., use `fps` instead of `a`,`b`,`c` for table  `fct_claims`)
- **Join Direction:** Always move from left to right in joins. Right joins often indicate a need to revise the table selection order.

### CTEs
- **Single Unit of Work:** Each CTE should perform a single, logical unit of work, where performance permits.
- **Data Limitation:** Limit the data scanned by CTEs by selecting only the needed columns and using `WHERE` clauses to filter data.
- **Verbose Naming:** Use descriptive names for CTEs to convey their purpose (e.g., `events_joined_to_users`).
- **Final Output:** The final line of a model should be `SELECT * FROM your_final_output_cte`. This allows for easy materialization and auditing of different model steps.

### GSheets - Fivetran Connector Standards
To ensure consistency, quality, and traceability in data models sourced from Google Sheets via Fivetran, follow these standards:

- **Not Null Tests**  
  Apply `not null` tests in your YAML files to guarantee data integrity on key columns:
  - `ID`
  - At least one key dimension or KPI field

- **Documentation Requirements**  
  In the corresponding `.md` file for each model, include:
  - A link to the original Google Sheet  
  - The owner or responsible contact for the sheet

These rules ensure transparency of ownership and data reliability across all Google Sheets sources.

## Getting Started
To get started with this project, you'll need to set up your local environment and understand how to execute models and tests within dbt. Here's a brief guide on the initial setup:

1. **Clone the Repository**: Clone this repository to your local machine using GitLab's repository tools.
2. **Install dbt**: Follow the [dbt installation guide](https://docs.getdbt.com/dbt-cli/installation) to set up dbt on your local system.
3. **Configure your profiles.yml**: Set up your `profiles.yml` to connect dbt to your data warehouse. This file should not be committed to the repository.
4. **Run dbt models**: Use the command `dbt run` to build your models locally and see the transformations take place.

## Contributing
We welcome contributions to this project. If you have suggestions for improvements or encounter any issues, please open an issue or submit a merge request with your proposed changes. See our contribution guidelines for more details on how to contribute effectively.
