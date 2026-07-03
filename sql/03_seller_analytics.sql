USE OpsLens;
GO

-- ============================================
-- SELLER PERFORMANCE RANKING
-- ============================================
WITH seller_metrics AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.price) AS total_revenue,
        ROUND(AVG(r.review_score), 2) AS avg_review_score,
        ROUND(
            100.0 * SUM(CASE WHEN o.is_late = 1 THEN 1 ELSE 0 END)
            / NULLIF(COUNT(DISTINCT oi.order_id), 0), 2
        ) AS late_delivery_pct
    FROM fact_order_items oi
    JOIN dim_sellers s ON oi.seller_id = s.seller_id
    JOIN fact_orders o ON oi.order_id = o.order_id
    LEFT JOIN fact_reviews r ON oi.order_id = r.order_id
    WHERE o.order_status NOT IN ('canceled', 'unavailable')
    GROUP BY oi.seller_id, s.seller_state
)
SELECT
    seller_id,
    seller_state,
    total_orders,
    total_revenue,
    avg_review_score,
    late_delivery_pct,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    NTILE(4) OVER (ORDER BY total_revenue DESC) AS revenue_quartile
FROM seller_metrics
ORDER BY total_revenue DESC;
GO