USE olist_analytics;

SELECT
    review_score,
    COUNT(*) AS num_reviews,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM order_reviews), 2) AS pct_of_total
FROM order_reviews
GROUP BY review_score
ORDER BY review_score;

SELECT
    CASE
        WHEN o.delivery_delay_days > 0 THEN 'Late'
        ELSE 'On-time or Early'
    END AS delivery_status,
    COUNT(*) AS num_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.is_delivered = 1
GROUP BY delivery_status;

SELECT
    p.product_category_name_english,
    COUNT(*) AS num_reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE o.is_delivered = 1
GROUP BY p.product_category_name_english
HAVING num_reviews >= 50
ORDER BY avg_review_score ASC
LIMIT 15;

SELECT
    c.customer_state,
    COUNT(*) AS num_reviews,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM order_reviews r
JOIN orders o ON r.order_id = o.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.is_delivered = 1
GROUP BY c.customer_state
ORDER BY avg_review_score ASC;

