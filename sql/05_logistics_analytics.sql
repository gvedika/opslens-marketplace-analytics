USE OpsLens;
GO

-- ============================================
-- LOGISTICS: DELIVERY PERFORMANCE BY STATE
-- ============================================
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(DAY, o.order_purchase_timestamp, o.order_delivered_customer_date)), 1) AS avg_delivery_days,
    ROUND(
        100.0 * SUM(CASE WHEN o.is_late = 1 THEN 1 ELSE 0 END)
        / NULLIF(SUM(CASE WHEN o.is_delivered = 1 THEN 1 ELSE 0 END), 0), 2
    ) AS late_delivery_pct
FROM fact_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
WHERE o.order_status NOT IN ('canceled', 'unavailable')
  AND o.is_delivered = 1
GROUP BY c.customer_state
ORDER BY late_delivery_pct DESC;
GO