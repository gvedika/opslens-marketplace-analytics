USE OpsLens;
GO

-- ============================================
-- CORE MARKETPLACE KPIs
-- ============================================
SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    COUNT(DISTINCT o.customer_id) AS active_customers,
    COUNT(DISTINCT oi.seller_id) AS active_sellers,
    ROUND(
        100.0 * SUM(CASE WHEN o.is_delivered = 1 THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS delivery_completion_rate_pct,
    ROUND(
        100.0 * SUM(CASE WHEN o.is_late = 1 THEN 1 ELSE 0 END) 
        / NULLIF(SUM(CASE WHEN o.is_delivered = 1 THEN 1 ELSE 0 END), 0), 2
    ) AS late_delivery_rate_pct
FROM fact_orders o
JOIN fact_order_items oi ON o.order_id = oi.order_id
WHERE o.order_status NOT IN ('canceled', 'unavailable');
GO

-- ============================================
-- AVERAGE REVIEW SCORE
-- ============================================
SELECT
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review_score,
    COUNT(r.review_id) AS total_reviews
FROM fact_reviews r;
GO

-- ============================================
-- MONTHLY REVENUE TREND (MoM Growth)
-- ============================================
WITH monthly_revenue AS (
    SELECT
        YEAR(o.order_purchase_timestamp) AS order_year,
        MONTH(o.order_purchase_timestamp) AS order_month,
        SUM(oi.price) AS revenue,
        COUNT(DISTINCT o.order_id) AS orders
    FROM fact_orders o
    JOIN fact_order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY YEAR(o.order_purchase_timestamp), MONTH(o.order_purchase_timestamp)
)
SELECT
    order_year,
    order_month,
    revenue,
    orders,
    LAG(revenue) OVER (ORDER BY order_year, order_month) AS prev_month_revenue,
    ROUND(
        100.0 * (revenue - LAG(revenue) OVER (ORDER BY order_year, order_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_year, order_month), 0), 2
    ) AS mom_growth_pct
FROM monthly_revenue
ORDER BY order_year, order_month;
GO