USE olist_analytics;

SELECT
    c.customer_unique_id,
    COUNT(DISTINCT o.order_id) AS frequency,
    ROUND(SUM(oit.order_total_value), 2) AS monetary,
    DATEDIFF(
        (SELECT MAX(order_purchase_timestamp) FROM orders WHERE is_delivered = 1),
        MAX(o.order_purchase_timestamp)
    ) AS recency_days
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_item_totals oit ON o.order_id = oit.order_id
WHERE o.is_delivered = 1
GROUP BY c.customer_unique_id
ORDER BY monetary DESC
LIMIT 20;

WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oit.order_total_value), 2) AS monetary,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders WHERE is_delivered = 1),
            MAX(o.order_purchase_timestamp)
        ) AS recency_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_item_totals oit ON o.order_id = oit.order_id
    WHERE o.is_delivered = 1
    GROUP BY c.customer_unique_id
),
thresholds AS (
    SELECT
        AVG(monetary) AS avg_monetary,
        AVG(recency_days) AS avg_recency
    FROM customer_metrics
)
SELECT
    cm.customer_unique_id,
    cm.frequency,
    cm.monetary,
    cm.recency_days,
    CASE
        WHEN cm.frequency >= 2 THEN 'Loyal / Repeat'
        WHEN cm.frequency = 1 AND cm.monetary >= t.avg_monetary AND cm.recency_days <= t.avg_recency THEN 'Recent High-Value'
        WHEN cm.frequency = 1 AND cm.monetary < t.avg_monetary AND cm.recency_days <= t.avg_recency THEN 'Recent Low-Value'
        WHEN cm.frequency = 1 AND cm.monetary >= t.avg_monetary AND cm.recency_days > t.avg_recency THEN 'Lapsed High-Value'
        ELSE 'Lapsed Low-Value'
    END AS customer_segment
FROM customer_metrics cm
CROSS JOIN thresholds t;

WITH customer_metrics AS (
    SELECT
        c.customer_unique_id,
        COUNT(DISTINCT o.order_id) AS frequency,
        ROUND(SUM(oit.order_total_value), 2) AS monetary,
        DATEDIFF(
            (SELECT MAX(order_purchase_timestamp) FROM orders WHERE is_delivered = 1),
            MAX(o.order_purchase_timestamp)
        ) AS recency_days
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    JOIN order_item_totals oit ON o.order_id = oit.order_id
    WHERE o.is_delivered = 1
    GROUP BY c.customer_unique_id
),
thresholds AS (
    SELECT
        AVG(monetary) AS avg_monetary,
        AVG(recency_days) AS avg_recency
    FROM customer_metrics
),
segmented AS (
    SELECT
        cm.*,
        CASE
            WHEN cm.frequency >= 2 THEN 'Loyal / Repeat'
            WHEN cm.frequency = 1 AND cm.monetary >= t.avg_monetary AND cm.recency_days <= t.avg_recency THEN 'Recent High-Value'
            WHEN cm.frequency = 1 AND cm.monetary < t.avg_monetary AND cm.recency_days <= t.avg_recency THEN 'Recent Low-Value'
            WHEN cm.frequency = 1 AND cm.monetary >= t.avg_monetary AND cm.recency_days > t.avg_recency THEN 'Lapsed High-Value'
            ELSE 'Lapsed Low-Value'
        END AS customer_segment
    FROM customer_metrics cm
    CROSS JOIN thresholds t
)
SELECT
    customer_segment,
    COUNT(*) AS num_customers,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(AVG(monetary), 2) AS avg_monetary,
    ROUND(AVG(recency_days), 1) AS avg_recency_days
FROM segmented
GROUP BY customer_segment
ORDER BY total_revenue DESC;