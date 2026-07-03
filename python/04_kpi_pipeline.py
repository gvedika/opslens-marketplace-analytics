import pandas as pd
from sqlalchemy import create_engine

server = 'localhost\\SQLEXPRESS'
database = 'OpsLens'
driver = 'ODBC Driver 18 for SQL Server'

connection_string = (
    f"mssql+pyodbc://@{server}/{database}"
    f"?driver={driver.replace(' ', '+')}"
    f"&trusted_connection=yes"
    f"&TrustServerCertificate=yes"
)
engine = create_engine(connection_string)

OUT = "data/processed"

# ------------------------------------------------------------------
# 1. Seller Health Score summary table (for Power BI)
# ------------------------------------------------------------------
print("Building seller_health_summary...")

seller_query = """
WITH seller_base AS (
    SELECT
        oi.seller_id,
        SUM(oi.price) AS total_revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        AVG(CAST(r.review_score AS FLOAT)) AS avg_review_score,
        100.0 * SUM(CASE WHEN o.is_late = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(DISTINCT oi.order_id), 0) AS late_pct
    FROM fact_order_items oi
    JOIN fact_orders o ON oi.order_id = o.order_id
    LEFT JOIN fact_reviews r ON oi.order_id = r.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY oi.seller_id
),
scored AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY total_revenue ASC) AS revenue_score,
        NTILE(4) OVER (ORDER BY avg_review_score ASC) AS review_score_pt,
        NTILE(4) OVER (ORDER BY late_pct DESC) AS delivery_score
    FROM seller_base
)
SELECT
    seller_id, total_revenue, total_orders, avg_review_score, late_pct,
    ROUND((revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3), 2) AS seller_health_score
FROM scored
"""
seller_health = pd.read_sql(seller_query, engine)

seller_health["seller_category"] = pd.cut(
    seller_health["seller_health_score"],
    bins=[0, 1.5, 2.5, 3.5, 5],
    labels=["High Risk", "Watchlist", "Stable", "Excellent"]
)
seller_health.to_csv(f"{OUT}/seller_health_summary.csv", index=False)
print(f"  -> {seller_health.shape[0]} sellers scored")

# ------------------------------------------------------------------
# 2. Customer RFM summary table (for Power BI)
# ------------------------------------------------------------------
print("Building customer_rfm_summary...")

rfm_query = """
WITH customer_orders AS (
    SELECT o.customer_id, MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency, SUM(oi.price) AS monetary
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY o.customer_id
),
rfm AS (
    SELECT customer_id, frequency, monetary,
        DATEDIFF(DAY, last_order_date, (SELECT MAX(order_purchase_timestamp) FROM fact_orders)) AS recency_days,
        NTILE(4) OVER (ORDER BY DATEDIFF(DAY, last_order_date, (SELECT MAX(order_purchase_timestamp) FROM fact_orders)) DESC) AS recency_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_orders
)
SELECT *,
    CASE
        WHEN frequency >= 2 THEN 'Repeat Customer'
        WHEN recency_score = 4 AND monetary_score = 4 THEN 'High-Value New'
        WHEN recency_score = 4 THEN 'Recent Customer'
        WHEN recency_score <= 2 AND monetary_score >= 3 THEN 'At Risk (High Value)'
        WHEN recency_score <= 2 THEN 'Lapsed'
        ELSE 'Regular'
    END AS customer_segment
FROM rfm
"""
rfm_df = pd.read_sql(rfm_query, engine)
rfm_df.to_csv(f"{OUT}/customer_rfm_summary.csv", index=False)
print(f"  -> {rfm_df.shape[0]} customers segmented")

print("\n✅ KPI pipeline complete. Summary files saved to data/processed/")