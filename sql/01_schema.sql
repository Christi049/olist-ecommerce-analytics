USE olist_analytics;

CREATE TABLE customers (
    customer_id VARCHAR(64) PRIMARY KEY,
    customer_unique_id VARCHAR(64),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

CREATE TABLE sellers (
    seller_id VARCHAR(64) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(5)
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT PRIMARY KEY,
    geolocation_lat DOUBLE,
    geolocation_lng DOUBLE,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);

CREATE TABLE products (
    product_id VARCHAR(64) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100),
    product_name_lenght FLOAT,
    product_description_lenght FLOAT,
    product_photos_qty FLOAT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);

CREATE TABLE orders (
    order_id VARCHAR(64) PRIMARY KEY,
    customer_id VARCHAR(64),
    order_status VARCHAR(20),
    is_delivered BOOLEAN,
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    delivery_days FLOAT,
    delivery_delay_days FLOAT,
    approval_days FLOAT,
    order_year INT,
    order_month INT,
    order_year_month VARCHAR(10),
    order_quarter INT,
    order_dow VARCHAR(15),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_id VARCHAR(64),
    order_item_id INT,
    product_id VARCHAR(64),
    seller_id VARCHAR(64),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_payments (
    order_id VARCHAR(64),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value FLOAT,
    PRIMARY KEY (order_id, payment_sequential),
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_reviews (
    review_id VARCHAR(64) PRIMARY KEY,
    order_id VARCHAR(64),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    has_comment_title BOOLEAN,
    has_comment_message BOOLEAN,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_item_totals (
    order_id VARCHAR(64) PRIMARY KEY,
    total_items INT,
    total_item_value FLOAT,
    total_freight_value FLOAT,
    order_total_value FLOAT,
    freight_pct FLOAT,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);