-- ============================================================================
-- BASIC BUSINESS QUERIES
-- ============================================================================
-- Purpose: Answer fundamental business questions
-- ============================================================================

USE customer_analytics;

-- ============================================================================
-- SECTION 1: REVENUE ANALYSIS
-- ============================================================================

-- Q1: Total revenue by gender
SELECT 
    gender,
    COUNT(*) as total_purchases,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(SUM(purchase_amount) * 100.0 / (SELECT SUM(purchase_amount) FROM customers), 2) as revenue_percentage
FROM customers
GROUP BY gender
ORDER BY total_revenue DESC;

-- Business Insight: Which gender contributes more to revenue?


-- Q2: Revenue by category
SELECT 
    category,
    COUNT(*) as sales_count,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(MIN(purchase_amount), 2) as min_purchase,
    ROUND(MAX(purchase_amount), 2) as max_purchase
FROM customers
GROUP BY category
ORDER BY total_revenue DESC;

-- Business Insight: Which categories are most profitable?


-- Q3: Revenue by season
SELECT 
    season,
    COUNT(*) as purchase_count,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase
FROM customers
GROUP BY season
ORDER BY total_revenue DESC;

-- Business Insight: Identify seasonal trends for inventory planning


-- Q4: Top 10 highest revenue generating items
SELECT 
    item_purchased,
    category,
    COUNT(*) as times_sold,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_price,
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
GROUP BY item_purchased, category
ORDER BY total_revenue DESC
LIMIT 10;

-- Business Insight: Focus marketing on top revenue items


-- ============================================================================
-- SECTION 2: CUSTOMER ANALYSIS
-- ============================================================================

-- Q5: Customer distribution by age group
SELECT 
    age_group,
    COUNT(DISTINCT customer_id) as customer_count,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(COUNT(DISTINCT customer_id) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM customers), 2) as percentage
FROM customers
GROUP BY age_group
ORDER BY total_revenue DESC;

-- Business Insight: Which age group is most valuable?


-- Q6: Customer segmentation analysis
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_id) as customer_count,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(previous_purchases), 2) as avg_previous_purchases,
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
GROUP BY customer_segment
ORDER BY total_revenue DESC;

-- Business Insight: Identify high-value customer segments


-- Q7: Top 20 customers by total spending
SELECT 
    customer_id,
    gender,
    age,
    age_group,
    customer_segment,
    COUNT(*) as purchase_count,
    ROUND(SUM(purchase_amount), 2) as total_spent,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(AVG(review_rating), 2) as avg_rating,
    subscription_status
FROM customers
GROUP BY customer_id, gender, age, age_group, customer_segment, subscription_status
ORDER BY total_spent DESC
LIMIT 20;

-- Business Insight: VIP customer identification for loyalty programs


-- ============================================================================
-- SECTION 3: SUBSCRIPTION ANALYSIS
-- ============================================================================

-- Q8: Subscription vs non-subscription comparison
SELECT 
    subscription_status,
    COUNT(DISTINCT customer_id) as customer_count,
    COUNT(*) as total_purchases,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(AVG(previous_purchases), 2) as avg_previous_purchases,
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
GROUP BY subscription_status
ORDER BY total_revenue DESC;

-- Business Insight: Quantify value of subscription program


-- Q9: Subscription rate by customer segment
SELECT 
    customer_segment,
    COUNT(*) as total_customers,
    SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) as subscribers,
    ROUND(SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as subscription_rate
FROM customers
GROUP BY customer_segment
ORDER BY subscription_rate DESC;

-- Business Insight: Which segments are most likely to subscribe?


-- Q10: Subscription rate by age group
SELECT 
    age_group,
    COUNT(*) as total_customers,
    SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) as subscribers,
    ROUND(SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as subscription_rate,
    ROUND(AVG(purchase_amount), 2) as avg_purchase
FROM customers
GROUP BY age_group
ORDER BY subscription_rate DESC;

-- Business Insight: Target age groups for subscription campaigns


-- ============================================================================
-- SECTION 4: DISCOUNT ANALYSIS
-- ============================================================================

-- Q11: Impact of discounts on purchases
SELECT 
    discount_applied,
    COUNT(*) as purchase_count,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
GROUP BY discount_applied
ORDER BY discount_applied;

-- Business Insight: Do discounts increase or decrease average purchase value?


-- Q12: Discount usage by category
SELECT 
    category,
    COUNT(*) as total_sales,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discounted_sales,
    ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as discount_rate,
    ROUND(AVG(CASE WHEN discount_applied = 'Yes' THEN purchase_amount END), 2) as avg_discounted_purchase,
    ROUND(AVG(CASE WHEN discount_applied = 'No' THEN purchase_amount END), 2) as avg_regular_purchase
FROM customers
GROUP BY category
ORDER BY discount_rate DESC;

-- Business Insight: Which categories rely most on discounts?


-- Q13: High-value customers who used discounts
SELECT 
    customer_id,
    gender,
    age_group,
    purchase_amount,
    category,
    item_purchased,
    review_rating
FROM customers
WHERE discount_applied = 'Yes'
    AND purchase_amount > (SELECT AVG(purchase_amount) FROM customers)
ORDER BY purchase_amount DESC
LIMIT 20;

-- Business Insight: Premium customers using discounts - potential for margin improvement


-- ============================================================================
-- SECTION 5: PRODUCT PERFORMANCE
-- ============================================================================

-- Q14: Top 5 products by average review rating
SELECT 
    item_purchased,
    category,
    COUNT(*) as times_purchased,
    ROUND(AVG(review_rating), 2) as avg_rating,
    ROUND(AVG(purchase_amount), 2) as avg_price,
    ROUND(SUM(purchase_amount), 2) as total_revenue
FROM customers
GROUP BY item_purchased, category
HAVING COUNT(*) >= 10  -- Only items with at least 10 reviews
ORDER BY avg_rating DESC, times_purchased DESC
LIMIT 5;

-- Business Insight: Highlight top-rated products in marketing


-- Q15: Worst performing products (low ratings, low sales)
SELECT 
    item_purchased,
    category,
    COUNT(*) as times_purchased,
    ROUND(AVG(review_rating), 2) as avg_rating,
    ROUND(AVG(purchase_amount), 2) as avg_price
FROM customers
GROUP BY item_purchased, category
HAVING COUNT(*) >= 5
ORDER BY avg_rating ASC, times_purchased ASC
LIMIT 10;

-- Business Insight: Consider discontinuing or improving these products


-- Q16: Product performance by color
SELECT 
    color,
    COUNT(*) as sales_count,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
GROUP BY color
ORDER BY total_revenue DESC
LIMIT 10;

-- Business Insight: Focus inventory on popular colors


-- ============================================================================
-- SECTION 6: SHIPPING & PAYMENT ANALYSIS
-- ============================================================================

-- Q17: Shipping type preferences and spending
SELECT 
    shipping_type,
    COUNT(*) as usage_count,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) as usage_percentage
FROM customers
GROUP BY shipping_type
ORDER BY usage_count DESC;

-- Business Insight: Optimize shipping options based on customer preferences


-- Q18: Payment method analysis
SELECT 
    payment_method,
    COUNT(*) as transaction_count,
    ROUND(AVG(purchase_amount), 2) as avg_transaction,
    ROUND(SUM(purchase_amount), 2) as total_value,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 2) as usage_percentage
FROM customers
GROUP BY payment_method
ORDER BY transaction_count DESC;

-- Business Insight: Understand preferred payment methods


-- Q19: Shipping cost impact analysis (Express vs Standard)
SELECT 
    shipping_type,
    COUNT(*) as shipment_count,
    ROUND(AVG(purchase_amount), 2) as avg_purchase_value,
    ROUND(AVG(review_rating), 2) as avg_rating,
    subscription_status,
    COUNT(CASE WHEN subscription_status = 'Yes' THEN 1 END) as subscribers
FROM customers
WHERE shipping_type IN ('Express', 'Standard')
GROUP BY shipping_type, subscription_status
ORDER BY shipping_type, subscription_status;

-- Business Insight: Do express shipping customers have higher lifetime value?


-- ============================================================================
-- SECTION 7: LOCATION ANALYSIS
-- ============================================================================

-- Q20: Top 10 locations by revenue
SELECT 
    location,
    COUNT(*) as purchase_count,
    COUNT(DISTINCT customer_id) as unique_customers,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) as subscribers
FROM customers
GROUP BY location
ORDER BY total_revenue DESC
LIMIT 10;

-- Business Insight: Target high-revenue locations for expansion


-- ============================================================================
-- SUMMARY STATISTICS
-- ============================================================================

-- Q21: Executive Summary Dashboard Query
SELECT 
    'Total Customers' as metric,
    COUNT(DISTINCT customer_id) as value
FROM customers
UNION ALL
SELECT 
    'Total Revenue',
    ROUND(SUM(purchase_amount), 2)
FROM customers
UNION ALL
SELECT 
    'Average Purchase',
    ROUND(AVG(purchase_amount), 2)
FROM customers
UNION ALL
SELECT 
    'Average Rating',
    ROUND(AVG(review_rating), 2)
FROM customers
UNION ALL
SELECT 
    'Subscription Rate (%)',
    ROUND(SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM customers
UNION ALL
SELECT 
    'Discount Usage Rate (%)',
    ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)
FROM customers;

-- ============================================================================
-- BASIC QUERIES COMPLETE
-- ============================================================================