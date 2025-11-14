-- ============================================================================
-- SCHEMA CREATION AND DATABASE SETUP
-- ============================================================================
-- Database: customer_analytics
-- Purpose: Customer shopping behavior analysis
-- ============================================================================

-- Create database
CREATE DATABASE IF NOT EXISTS customer_analytics;
USE customer_analytics;

-- ============================================================================
-- TABLE DESCRIPTIONS
-- ============================================================================

-- Display existing tables
SHOW TABLES;

-- View structure of main customers table
DESCRIBE customers;

-- Get table sizes
SELECT 
    table_name AS 'Table',
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)',
    table_rows AS 'Rows'
FROM information_schema.TABLES
WHERE table_schema = 'customer_analytics'
ORDER BY (data_length + index_length) DESC;

-- ============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Index on customer_id for faster joins
CREATE INDEX idx_customer_id ON customers(customer_id);

-- Index on category for faster filtering
CREATE INDEX idx_category ON customers(category);

-- Index on subscription_status for faster aggregations
CREATE INDEX idx_subscription ON customers(subscription_status);

-- Index on customer_segment
CREATE INDEX idx_segment ON customers(customer_segment);

-- Composite index for common queries
CREATE INDEX idx_category_subscription ON customers(category, subscription_status);

-- Verify indexes
SHOW INDEXES FROM customers;

-- ============================================================================
-- DATA QUALITY CHECKS
-- ============================================================================

-- Check for NULL values in critical columns
SELECT 
    'customer_id' as column_name,
    COUNT(*) - COUNT(customer_id) as null_count
FROM customers
UNION ALL
SELECT 
    'purchase_amount',
    COUNT(*) - COUNT(purchase_amount)
FROM customers
UNION ALL
SELECT 
    'age',
    COUNT(*) - COUNT(age)
FROM customers
UNION ALL
SELECT 
    'category',
    COUNT(*) - COUNT(category)
FROM customers;

-- Check for duplicate customer_id entries
SELECT 
    customer_id,
    COUNT(*) as occurrence_count
FROM customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Data range validation
SELECT 
    'Age Range' as check_type,
    MIN(age) as min_value,
    MAX(age) as max_value,
    AVG(age) as avg_value
FROM customers
UNION ALL
SELECT 
    'Purchase Amount Range',
    MIN(purchase_amount),
    MAX(purchase_amount),
    AVG(purchase_amount)
FROM customers
UNION ALL
SELECT 
    'Review Rating Range',
    MIN(review_rating),
    MAX(review_rating),
    AVG(review_rating)
FROM customers;

-- ============================================================================
-- SUMMARY STATISTICS
-- ============================================================================

-- Overall dataset summary
SELECT 
    COUNT(*) as total_records,
    COUNT(DISTINCT customer_id) as unique_customers,
    COUNT(DISTINCT category) as unique_categories,
    COUNT(DISTINCT item_purchased) as unique_items,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase_amount,
    ROUND(AVG(review_rating), 2) as avg_review_rating
FROM customers;

-- Distribution by key dimensions
SELECT 
    'Gender' as dimension,
    gender as value,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) as percentage
FROM customers
GROUP BY gender
UNION ALL
SELECT 
    'Subscription',
    subscription_status,
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2)
FROM customers
GROUP BY subscription_status
UNION ALL
SELECT 
    'Discount Applied',
    discount_applied,
    COUNT(*),
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2)
FROM customers
GROUP BY discount_applied
ORDER BY dimension, count DESC;

-- ============================================================================
-- CREATE VIEWS FOR COMMON QUERIES
-- ============================================================================

-- View: Customer Spending Summary
CREATE OR REPLACE VIEW vw_customer_spending_summary AS
SELECT 
    customer_id,
    gender,
    age,
    age_group,
    customer_segment,
    subscription_status,
    COUNT(*) as total_purchases,
    ROUND(SUM(purchase_amount), 2) as total_spent,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(AVG(review_rating), 2) as avg_rating,
    MAX(purchase_amount) as max_purchase
FROM customers
GROUP BY customer_id, gender, age, age_group, customer_segment, subscription_status;

-- View: Category Performance
CREATE OR REPLACE VIEW vw_category_performance AS
SELECT 
    category,
    COUNT(*) as total_sales,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_sale_value,
    ROUND(AVG(review_rating), 2) as avg_rating,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discounted_sales,
    ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as discount_rate
FROM customers
GROUP BY category;

-- View: Subscription Analysis
CREATE OR REPLACE VIEW vw_subscription_analysis AS
SELECT 
    subscription_status,
    COUNT(DISTINCT customer_id) as customer_count,
    COUNT(*) as total_purchases,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
GROUP BY subscription_status;

-- Verify views created
SHOW FULL TABLES WHERE Table_type = 'VIEW';

-- ============================================================================
-- SCHEMA CREATION COMPLETE
-- ============================================================================

SELECT '✅ Schema creation and setup complete!' as status;