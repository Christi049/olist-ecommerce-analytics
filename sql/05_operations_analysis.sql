USE olist_analytics;

SELECT
    COUNT(*) AS total_delivered_orders,
    ROUND(AVG(delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(delivery_delay_days), 1) AS avg_delay_days,
    SUM(CASE WHEN delivery_delay_days > 0 THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN delivery_delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late,
    ROUND(100.0 * SUM(CASE WHEN delivery_delay_days <= 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_on_time
FROM orders
WHERE is_delivered = 1;

SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
    ROUND(AVG(o.delivery_delay_days), 1) AS avg_delay_days,
    ROUND(100.0 * SUM(CASE WHEN o.delivery_delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.is_delivered = 1
GROUP BY c.customer_state
ORDER BY pct_late DESC;

SELECT
    p.product_category_name_english,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN o.delivery_delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.is_delivered = 1
GROUP BY p.product_category_name_english
HAVING total_orders >= 50
ORDER BY pct_late DESC
LIMIT 15;

SELECT
    oi.seller_id,
    s.seller_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(o.delivery_days), 1) AS avg_delivery_days,
    ROUND(100.0 * SUM(CASE WHEN o.delivery_delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_late
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.is_delivered = 1
GROUP BY oi.seller_id, s.seller_state
HAVING total_orders >= 30
ORDER BY pct_late DESC
LIMIT 15;

