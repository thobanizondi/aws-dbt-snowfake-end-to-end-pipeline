# 🚀 AWS · dbt · Snowflake End-to-End Data Pipeline

> A production-style cloud data engineering pipeline built on a modern lakehouse stack — ingesting Airbnb-style rental data from AWS S3, transforming it through a Bronze → Silver → Gold architecture using dbt, and landing analytics-ready tables in Snowflake.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Data Model](#data-model)
- [Pipeline Layers](#pipeline-layers)
  - [Bronze Layer](#bronze-layer)
  - [Silver Layer](#silver-layer)
  - [Gold Layer](#gold-layer)
  - [Snapshots (SCD Type 2)](#snapshots-scd-type-2)
- [Dataset](#dataset)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [dbt Commands](#dbt-commands)
- [Data Quality Tests](#data-quality-tests)
- [Author](#author)

---

## Overview

This project demonstrates a **production-style end-to-end data engineering pipeline** built on a modern cloud stack. Raw short-term rental data (listings, bookings, and hosts) is ingested from **AWS S3** into **Snowflake** as the central data warehouse, transformed and modelled across three layers using **dbt**, and version-controlled throughout via **GitHub**.

The pipeline follows the **Medallion Architecture** (Bronze → Silver → Gold), a widely adopted pattern in enterprise data engineering used across finance, banking, and tech industries.

---

## Architecture

```
┌─────────────┐     ┌──────────────────┐     ┌─────────────────────────────────────┐
│             │     │                  │     │           SNOWFLAKE                  │
│   Raw CSV   │────▶│    AWS S3        │────▶│  ┌─────────┐ ┌────────┐ ┌────────┐  │
│   Files     │     │  (Data Lake)     │     │  │ Bronze  │▶│ Silver │▶│  Gold  │  │
│             │     │                  │     │  └─────────┘ └────────┘ └────────┘  │
└─────────────┘     └──────────────────┘     └─────────────────────────────────────┘
                                                          ▲
                                                          │
                                                    ┌─────────┐
                                                    │   dbt   │
                                                    │(Transform│
                                                    │ & Test) │
                                                    └─────────┘
```

---

## Tech Stack

| Tool | Purpose | Version |
|------|---------|---------|
| **AWS S3** | Raw data storage and ingestion layer | — |
| **Snowflake** | Cloud data warehouse (UAE North, Azure) | Business Critical |
| **dbt** | Data transformation, modelling and testing | 1.11.11 |
| **dbt-snowflake** | Snowflake adapter for dbt | 1.11.5 |
| **Python** | Pipeline scripting and environment management | 3.12.0 |
| **uv** | Python package manager | — |
| **GitHub** | Version control and portfolio showcase | — |

---

## Data Model

```
                        ┌──────────────┐
                        │ dim_listings │
                        └──────┬───────┘
                               │
┌──────────┐     ┌─────────────▼──────────┐     ┌──────────────┐
│ dim_hosts│────▶│     fact_bookings      │◀────│  dim_bookings│
└──────────┘     │   (one_big_table)      │     │  (SCD Type 2)│
                 └────────────────────────┘     └──────────────┘
```

---

## Pipeline Layers

### Bronze Layer

> Raw ingestion — minimal transformation, full fidelity from source.

| Model | Source | Materialization | Description |
|-------|--------|----------------|-------------|
| `bronze_listings` | `STAGING.LISTINGS` | Incremental | Raw property listings |
| `bronze_bookings` | `STAGING.BOOKINGS` | Incremental | Raw booking transactions |
| `bronze_hosts` | `STAGING.HOSTS` | Incremental | Raw host profiles |

Incremental strategy uses `CREATED_AT` watermarking to load only new records on each run.

---

### Silver Layer

> Cleaned, enriched, and business-ready data.

| Model | Source | Materialization | Key Transformations |
|-------|--------|----------------|-------------------|
| `silver_listings` | `bronze_listings` | Incremental | Type casting, standardisation |
| `silver_bookings` | `bronze_bookings` | Incremental | Total price calculation via custom `multiply()` macro |
| `silver_hosts` | `bronze_hosts` | Incremental | Response rate quality banding (VERY GOOD / GOOD / FAIR / POOR), host name formatting |

Custom dbt macro `multiply(x, y, precision)` used for precise decimal arithmetic.

---

### Gold Layer

> Analytics-ready, business-facing tables.

| Model | Materialization | Description |
|-------|----------------|-------------|
| `one_big_table` | Table | Denormalised OBT joining bookings, listings, and hosts |
| `fact_bookings` | Table | Fact table with key booking metrics |
| `dim_listings` | Table | Property dimension |
| `dim_hosts` | Table | Host dimension with quality ratings |

Jinja-powered dynamic SQL using `{% set config %}` loops for flexible join logic.

---

### Snapshots (SCD Type 2)

> Historical change tracking using dbt snapshots.

| Snapshot | Strategy | Tracked On | Description |
|----------|---------|-----------|-------------|
| `dim_bookings` | Timestamp | `created_at` | Tracks booking status changes over time |
| `dim_hosts` | Timestamp | `created_at` | Tracks host profile changes over time |

SCD Type 2 adds `dbt_valid_from`, `dbt_valid_to`, and `dbt_scd_id` columns automatically.

---

## Dataset

| File | Rows | Description |
|------|------|-------------|
| `listings.csv` | 500 | Property details — type, location, pricing, capacity |
| `bookings.csv` | 5,000 | Reservation records — dates, amounts, status |
| `hosts.csv` | 200 | Host profiles — superhost status, response rates |

---

## Project Structure

```
aws-dbt-snowfake-end-to-end-pipeline/
│
├── aws_dbt_snowflake_project/
│   ├── models/
│   │   ├── bronze/                  # Raw ingestion layer
│   │   │   ├── bronze_bookings.sql
│   │   │   ├── bronze_hosts.sql
│   │   │   └── bronze_listings.sql
│   │   │
│   │   ├── silver/                  # Cleaned & enriched layer
│   │   │   ├── silver_bookings.sql
│   │   │   ├── silver_hosts.sql
│   │   │   ├── silver_listings.sql
│   │   │   └── schema.yml
│   │   │
│   │   ├── gold/                    # Analytics-ready layer
│   │   │   ├── one_big_table.sql
│   │   │   ├── fact_bookings.sql
│   │   │   └── ephemeral/
│   │   │       ├── bookings.sql
│   │   │       ├── hosts.sql
│   │   │       └── listings.sql
│   │   │
│   │   └── sources/
│   │       └── sources.yml
│   │
│   ├── macros/
│   │   ├── multiply.sql             # Custom precision multiply macro
│   │   └── generate_schema_name.sql # Custom schema naming macro
│   │
│   ├── snapshots/
│   │   ├── dim_bookings.yml
│   │   └── dim_hosts.yml
│   │
│   ├── tests/
│   │   └── source_tests.sql         # Custom singular data quality test
│   │
│   └── dbt_project.yml
│
├── files/
│   ├── listings.csv
│   ├── bookings.csv
│   └── hosts.csv
│
├── main.py
└── README.md
```

---

## Getting Started

### Prerequisites

- Python 3.12+
- Snowflake account
- AWS account with S3 bucket
- `uv` package manager

### Installation

```bash
# Clone the repository
git clone https://github.com/thobanizondi/aws-dbt-snowfake-end-to-end-pipeline.git
cd aws-dbt-snowfake-end-to-end-pipeline

# Create virtual environment and install dependencies
uv venv
source .venv/Scripts/activate  # Windows Git Bash
uv add dbt-snowflake
```

### Configure Snowflake Connection

Create `~/.dbt/profiles.yml`:

```yaml
aws_dbt_snowflake_project:
  outputs:
    dev:
      type: snowflake
      account: your_account_identifier
      database: AIRBNB_DB
      user: your_username
      password: your_password
      role: ACCOUNTADMIN
      schema: dbt_schema
      threads: 1
      warehouse: COMPUTE_WH
  target: dev
```

---

## dbt Commands

```bash
# Test Snowflake connection
dbt debug

# Compile models (no execution)
dbt compile

# Run all models
dbt run

# Run specific layer
dbt run --select bronze
dbt run --select silver
dbt run --select gold

# Run snapshots
dbt snapshot

# Run data quality tests
dbt test

# Generate and serve documentation
dbt docs generate
dbt docs serve
```

---

## Data Quality Tests

| Test | Type | Model | Description |
|------|------|-------|-------------|
| `unique` | Generic | `silver_bookings.booking_id` | No duplicate bookings |
| `not_null` | Generic | `silver_bookings.booking_id` | Booking ID always present |
| `unique` | Generic | `silver_listings.listing_id` | No duplicate listings |
| `not_null` | Generic | `silver_hosts.host_id` | Host ID always present |
| `booking_amount_min` | Singular | `STAGING.BOOKINGS` | Flags bookings below minimum threshold |

---

## Author

**Thobani Zondi**
Data Engineer | SQL Developer | Cloud Data Enthusiast

- 🌐 Portfolio: [datascienceportfol.io](https://datascienceportfol.io)
- 💻 GitHub: [github.com/thobanizondi](https://github.com/thobanizondi)
- 📍 Johannesburg, South Africa

---

*Built with ❤️ using dbt, Snowflake, and AWS*