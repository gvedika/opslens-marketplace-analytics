# OpsLens — Marketplace Operations Intelligence Platform

An end-to-end business intelligence platform built on the Olist Brazilian E-commerce dataset, simulating the internal analytics tools used by marketplace companies like Amazon, Flipkart, and Meesho to monitor operations, investigate issues, and drive data-backed business decisions.

## Overview

OpsLens moves beyond simple dashboards into a decision-support platform — enabling analysts to monitor marketplace health, investigate root causes of performance changes, and generate actionable business recommendations across seller performance, customer retention, and logistics.

The project follows a full analytics workflow: raw data → cleaning → relational modeling → SQL analytics → KPI engineering → interactive dashboard → business recommendations.

## Tech Stack

| Layer | Tools |
|---|---|
| Database | SQL Server Express, T-SQL |
| Data Processing | Python (pandas, numpy, SQLAlchemy) |
| Visualization | Power BI |
| Version Control | Git, GitHub |

## Key Findings

- **Customer retention gap** — 97% of customers are one-time buyers (98,199 orders across 98,199 unique customers), representing a major unrealized revenue opportunity
- **Geographic delivery disparity** — Northeast Brazilian states (AL, MA, PI, CE, SE) show late-delivery rates of 15–24%, vs. 5.9% in São Paulo, driven by distance from seller concentration
- **Seasonal logistics strain** — Marketplace Health Score dips sharply during Nov 2017 and Mar 2018, both high-volume periods where late-delivery rates spiked above 13%
- **Seller performance spread** — a composite Seller Health Score (revenue, review score, delivery reliability) flags 149 sellers (4.9%) as High Risk and 86 sellers (2.8%) as Excellent but underexposed
- **Payment behavior** — credit card accounts for 74% of transaction volume with a notably higher average order value (₹163) than boleto or voucher payments

Full analysis and 10 data-backed recommendations are documented in [`docs/Recommendation_Framework.md`](docs/Recommendation_Framework.md).

## Data Model

A star schema built in SQL Server:

- **Dimension tables:** `dim_customers`, `dim_sellers`, `dim_products`, `dim_geography`, `dim_date`
- **Fact tables:** `fact_orders`, `fact_order_items`, `fact_payments`, `fact_reviews`

## Analytics Highlights

- Core marketplace KPIs (revenue, AOV, delivery SLA, review score) via SQL
- Month-over-month revenue growth using window functions (`LAG`)
- Seller performance ranking using `RANK()` and `NTILE()`
- Customer RFM (Recency, Frequency, Monetary) segmentation via CTEs
- Composite Seller Health Score and Marketplace Health Score formulas
- A Python KPI pipeline that reproduces key SQL analyses as reusable summary tables for the dashboard layer

Every metric's formula and business meaning is documented in [`docs/KPI_Dictionary.md`](docs/KPI_Dictionary.md).

## Project Structure

```
opslens-marketplace-analytics/
├── data/
│   ├── raw/              # Original Olist CSVs (not committed — see setup)
│   └── processed/         # Cleaned data + KPI summary tables
├── sql/                   # All analytical SQL queries (schema, KPIs, RFM, health scores)
├── python/                # Data cleaning + KPI pipeline scripts
├── docs/                  # KPI dictionary, recommendation framework
└── powerbi/                # Power BI dashboard file
```

## Setup

1. Download the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle into `data/raw/`
2. Install dependencies: `pip install pandas numpy sqlalchemy pyodbc --break-system-packages`
3. Run `python/02_clean_data.py` to clean and transform the raw data
4. Run `sql/01_create_schema.sql` in SQL Server Management Studio to create the star schema
5. Run `python/03_load_data.py` to load cleaned data into SQL Server
6. Run the analytics scripts in `sql/` (files `02` through `07`) to reproduce all KPIs and findings
7. Open `powerbi/OpsLens.pbix` in Power BI Desktop to explore the interactive dashboard

## Documentation

- [KPI Dictionary](docs/KPI_Dictionary.md) — every metric's formula and business meaning
- [Recommendation Framework](docs/Recommendation_Framework.md) — 10 data-backed business recommendations

## Author

Built as an end-to-end analytics portfolio project demonstrating SQL proficiency, relational data modeling, business analysis, and interactive dashboard development.