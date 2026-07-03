USE OpsLens;
GO

-- ============================================
-- SELLER HEALTH SCORE
-- ============================================
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
    SELECT
        seller_id,
        total_revenue,
        total_orders,
        ROUND(avg_review_score, 2) AS avg_review_score,
        ROUND(late_pct, 2) AS late_pct,
        NTILE(4) OVER (ORDER BY total_revenue ASC) AS revenue_score,
        NTILE(4) OVER (ORDER BY avg_review_score ASC) AS review_score_pt,
        NTILE(4) OVER (ORDER BY late_pct DESC) AS delivery_score
    FROM seller_base
)
SELECT
    seller_id,
    total_revenue,
    total_orders,
    avg_review_score,
    late_pct,
    ROUND((revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3), 2) AS seller_health_score,
    CASE
        WHEN (revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3) >= 3.5 THEN 'Excellent'
        WHEN (revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3) >= 2.5 THEN 'Stable'
        WHEN (revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3) >= 1.5 THEN 'Watchlist'
        ELSE 'High Risk'
    END AS seller_category
FROM scored
ORDER BY seller_health_score DESC;
GO
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
    SELECT
        seller_id,
        NTILE(4) OVER (ORDER BY total_revenue ASC) AS revenue_score,
        NTILE(4) OVER (ORDER BY avg_review_score ASC) AS review_score_pt,
        NTILE(4) OVER (ORDER BY late_pct DESC) AS delivery_score
    FROM seller_base
),
final AS (
    SELECT
        seller_id,
        CASE
            WHEN (revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3) >= 3.5 THEN 'Excellent'
            WHEN (revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3) >= 2.5 THEN 'Stable'
            WHEN (revenue_score * 0.3 + review_score_pt * 0.4 + delivery_score * 0.3) >= 1.5 THEN 'Watchlist'
            ELSE 'High Risk'
        END AS seller_category
    FROM scored
)
SELECT seller_category, COUNT(*) AS seller_count
FROM final
GROUP BY seller_category
ORDER BY seller_count DESC;
GO
-- ============================================
-- MARKETPLACE HEALTH SCORE (Executive Composite)
-- ============================================
WITH monthly_metrics AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS yr,
        MONTH(o.order_purchase_timestamp) AS mo,
        SUM(oi.price) AS revenue,
        COUNT(DISTINCT o.order_id) AS orders,
        AVG(CAST(r.review_score AS FLOAT)) AS avg_review,
        100.0 * SUM(CASE WHEN o.is_delivered = 1 THEN 1 ELSE 0 END) / COUNT(*) AS delivery_rate,
        100.0 * SUM(CASE WHEN o.is_late = 1 THEN 1 ELSE 0 END) 
            / NULLIF(SUM(CASE WHEN o.is_delivered = 1 THEN 1 ELSE 0 END), 0) AS late_rate
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    LEFT JOIN fact_reviews r ON o.order_id = r.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
      AND YEAR(o.order_purchase_timestamp) >= 2017  -- exclude 2016 pilot noise
    GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
),
scored AS (
    SELECT
        yr, mo, revenue, orders, avg_review, delivery_rate, late_rate,
        NTILE(4) OVER (ORDER BY revenue ASC) AS revenue_score,
        NTILE(4) OVER (ORDER BY avg_review ASC) AS review_score,
        NTILE(4) OVER (ORDER BY delivery_rate ASC) AS delivery_score,
        NTILE(4) OVER (ORDER BY late_rate DESC) AS late_score
    FROM monthly_metrics
)
SELECT
    yr, mo, revenue, orders,
    ROUND(avg_review, 2) AS avg_review_score,
    ROUND(delivery_rate, 2) AS delivery_completion_pct,
    ROUND(late_rate, 2) AS late_delivery_pct,
    ROUND((revenue_score * 0.3 + review_score * 0.3 + delivery_score * 0.2 + late_score * 0.2), 2) AS marketplace_health_score
FROM scored
ORDER BY yr, mo;
GO