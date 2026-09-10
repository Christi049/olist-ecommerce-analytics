USE olist_analytics;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE customers;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/customers_clean.csv'
INTO TABLE customers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

TRUNCATE TABLE sellers;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/sellers_clean.csv'
INTO TABLE sellers FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(seller_id, seller_zip_code_prefix, seller_city, seller_state);

TRUNCATE TABLE geolocation;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/geolocation_clean.csv'
INTO TABLE geolocation FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

TRUNCATE TABLE products;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/products_clean.csv'
INTO TABLE products FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(product_id, product_category_name, product_name_lenght, product_description_lenght,
 product_photos_qty, product_weight_g, product_length_cm, product_height_cm,
 product_width_cm, product_category_name_english);

TRUNCATE TABLE orders;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/orders_clean.csv'
INTO TABLE orders FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at,
 order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date,
 is_delivered, delivery_days, delivery_delay_days, approval_days, order_year, order_month,
 order_year_month, order_quarter, order_dow);

TRUNCATE TABLE order_items;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/order_items_clean.csv'
INTO TABLE order_items FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value);

TRUNCATE TABLE order_payments;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/payments_clean.csv'
INTO TABLE order_payments FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(order_id, payment_sequential, payment_type, payment_installments, payment_value);

TRUNCATE TABLE order_reviews;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/reviews_clean.csv'
INTO TABLE order_reviews FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(review_id, order_id, review_score, review_comment_title, review_comment_message,
 review_creation_date, review_answer_timestamp, has_comment_message, has_comment_title);

TRUNCATE TABLE order_item_totals;
LOAD DATA LOCAL INFILE 'C:/Users/us/da/data/processed/order_item_totals.csv'
INTO TABLE order_item_totals FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS
(order_id, total_items, total_item_value, total_freight_value, order_total_value, freight_pct);

SET FOREIGN_KEY_CHECKS = 1;

UPDATE orders SET is_delivered = (order_status = 'delivered');
UPDATE order_reviews
SET has_comment_title = (review_comment_title IS NOT NULL AND review_comment_title != ''),
    has_comment_message = (review_comment_message IS NOT NULL AND review_comment_message != '');

