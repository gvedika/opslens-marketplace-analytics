USE OpsLens;
GO

-- ============================================
-- CUSTOMER RFM SEGMENTATION
-- ============================================
WITH customer_orders AS (
    SELECT
        o.customer_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price) AS monetary
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY o.customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        DATEDIFF(DAY, last_order_date, (SELECT MAX(order_purchase_timestamp) FROM fact_orders)) AS recency_days,
        frequency,
        monetary,
        NTILE(4) OVER (ORDER BY DATEDIFF(DAY, last_order_date, (SELECT MAX(order_purchase_timestamp) FROM fact_orders)) DESC) AS recency_score,
        NTILE(4) OVER (ORDER BY frequency ASC) AS frequency_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_orders
)
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    recency_score,
    monetary_score,
    CASE
        WHEN frequency >= 2 THEN 'Repeat Customer'
        WHEN recency_score = 4 AND monetary_score = 4 THEN 'High-Value New'
        WHEN recency_score = 4 THEN 'Recent Customer'
        WHEN recency_score <= 2 AND monetary_score >= 3 THEN 'At Risk (High Value)'
        WHEN recency_score <= 2 THEN 'Lapsed'
        ELSE 'Regular'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary DESC;
GO
WITH customer_orders AS (
    SELECT
        o.customer_id,
        MAX(o.order_purchase_timestamp) AS last_order_date,
        COUNT(DISTINCT o.order_id) AS frequency,
        SUM(oi.price) AS monetary
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY o.customer_id
),
rfm_scores AS (
    SELECT
        customer_id, frequency, monetary,
        NTILE(4) OVER (ORDER BY DATEDIFF(DAY, last_order_date, (SELECT MAX(order_purchase_timestamp) FROM fact_orders)) DESC) AS recency_score,
        NTILE(4) OVER (ORDER BY monetary ASC) AS monetary_score
    FROM customer_orders
),
segmented AS (
    SELECT *,
        CASE
            WHEN frequency >= 2 THEN 'Repeat Customer'
            WHEN recency_score = 4 AND monetary_score = 4 THEN 'High-Value New'
            WHEN recency_score = 4 THEN 'Recent Customer'
            WHEN recency_score <= 2 AND monetary_score >= 3 THEN 'At Risk (High Value)'
            WHEN recency_score <= 2 THEN 'Lapsed'
            ELSE 'Regular'
        END AS customer_segment
    FROM rfm_scores
)
SELECT customer_segment, COUNT(*) AS customer_count
FROM segmented
GROUP BY customer_segment
ORDER BY customer_count DESC;
GO