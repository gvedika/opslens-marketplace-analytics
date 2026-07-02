USE OpsLens;
GO

-- ============================================
-- DIMENSION TABLES
-- ============================================

CREATE TABLE dim_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);

CREATE TABLE dim_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(5)
);

CREATE TABLE dim_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100),
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);

CREATE TABLE dim_geography (
    geolocation_zip_code_prefix INT PRIMARY KEY,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);

CREATE TABLE dim_date (
    date_key DATE PRIMARY KEY,
    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    day INT,
    weekday INT,
    weekday_name VARCHAR(20),
    is_weekend BIT
);

-- ============================================
-- FACT TABLES
-- ============================================

CREATE TABLE fact_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) FOREIGN KEY REFERENCES dim_customers(customer_id),
    order_status VARCHAR(30),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    is_delivered BIT,
    is_late BIT
);

CREATE TABLE fact_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50) FOREIGN KEY REFERENCES dim_products(product_id),
    seller_id VARCHAR(50) FOREIGN KEY REFERENCES dim_sellers(seller_id),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id)
);

CREATE TABLE fact_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(30),
    payment_installments INT,
    payment_value FLOAT,
    PRIMARY KEY (order_id, payment_sequential)
);

CREATE TABLE fact_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);

PRINT 'Schema created successfully.';