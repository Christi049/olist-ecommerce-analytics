USE olist_analytics;

SELECT
    o.order_year_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oit.order_total_value), 2) AS total_revenue,
    ROUND(AVG(oit.order_total_value), 2) AS avg_order_value
FROM orders o
JOIN order_item_totals oit ON o.order_id = oit.order_id
WHERE o.is_delivered = 1
GROUP BY o.order_year_month
ORDER BY o.order_year_month;

SELECT
    p.product_category_name_english,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_item_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.is_delivered = 1
GROUP BY p.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 20;

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oit.order_total_value), 2) AS total_revenue,
    ROUND(AVG(oit.order_total_value), 2) AS avg_order_value
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_item_totals oit ON o.order_id = oit.order_id
WHERE o.is_delivered = 1
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

SELECT
    p.product_category_name_english,
    SUM(CASE WHEN o.order_year = 2017 THEN oi.price ELSE 0 END) AS revenue_2017,
    SUM(CASE WHEN o.order_year = 2018 THEN oi.price ELSE 0 END) AS revenue_2018
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.is_delivered = 1 AND o.order_year IN (2017, 2018)
GROUP BY p.product_category_name_english
HAVING revenue_2017 > 1000
ORDER BY (revenue_2018 - revenue_2017) DESC;

