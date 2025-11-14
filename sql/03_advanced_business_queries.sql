-- ============================================================================
-- ADVANCED BUSINESS ANALYTICS QUERIES
-- ============================================================================
-- Purpose: Complex analytical queries for strategic decision-making
-- ============================================================================

USE customer_analytics;

-- ============================================================================
-- SECTION 1: CUSTOMER LIFETIME VALUE (CLV) ANALYSIS
-- ============================================================================

-- Q1: Customer Value Tiers with Detailed Metrics
WITH customer_metrics AS (
    SELECT 
        customer_id,
        gender,
        age_group,
        customer_segment,
        subscription_status,
        COUNT(*) as purchase_count,
        ROUND(SUM(purchase_amount), 2) as total_spent,
        ROUND(AVG(purchase_amount), 2) as avg_order_value,
        ROUND(AVG(review_rating), 2) as avg_rating,
        MAX(purchase_amount) as highest_purchase,
        SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discount_usage
    FROM customers
    GROUP BY customer_id, gender, age_group, customer_segment, subscription_status
),
value_tiers AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY total_spent) as value_quartile,
        CASE 
            WHEN total_spent >= (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY total_spent) FROM customer_metrics) THEN 'Premium'
            WHEN total_spent >= (SELECT PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY total_spent) FROM customer_metrics) THEN 'High Value'
            WHEN total_spent >= (SELECT PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY total_spent) FROM customer_metrics) THEN 'Medium Value'
            ELSE 'Low Value'
        END as value_tier
    FROM customer_metrics
)
SELECT 
    value_tier,
    COUNT(*) as customer_count,
    ROUND(AVG(total_spent), 2) as avg_lifetime_value,
    ROUND(SUM(total_spent), 2) as total_tier_revenue,
    ROUND(AVG(purchase_count), 2) as avg_purchases,
    ROUND(AVG(avg_order_value), 2) as avg_order_value,
    ROUND(AVG(avg_rating), 2) as avg_satisfaction,
    ROUND(SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as subscription_rate
FROM value_tiers
GROUP BY value_tier
ORDER BY avg_lifetime_value DESC;

-- Business Impact: Identify and focus on high-value customers


-- Q2: Customer Cohort Analysis by Segment Evolution
SELECT 
    customer_segment,
    age_group,
    COUNT(DISTINCT customer_id) as customer_count,
    ROUND(AVG(previous_purchases), 2) as avg_purchase_history,
    ROUND(AVG(purchase_amount), 2) as avg_current_purchase,
    ROUND(SUM(purchase_amount), 2) as total_revenue,
    SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) as subscribers,
    ROUND(SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT customer_id), 2) as subscription_rate
FROM customers
GROUP BY customer_segment, age_group
ORDER BY customer_segment, total_revenue DESC;

-- Business Impact: Understand customer journey from new to loyal


-- ============================================================================
-- SECTION 2: REVENUE OPTIMIZATION OPPORTUNITIES
-- ============================================================================

-- Q3: Discount Dependency Analysis - Products that only sell with discounts
WITH product_performance AS (
    SELECT 
        item_purchased,
        category,
        COUNT(*) as total_sales,
        SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discounted_sales,
        ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as discount_dependency,
        ROUND(AVG(CASE WHEN discount_applied = 'Yes' THEN purchase_amount END), 2) as avg_discounted_price,
        ROUND(AVG(CASE WHEN discount_applied = 'No' THEN purchase_amount END), 2) as avg_full_price,
        ROUND(AVG(review_rating), 2) as avg_rating
    FROM customers
    GROUP BY item_purchased, category
    HAVING COUNT(*) >= 5
)
SELECT 
    item_purchased,
    category,
    total_sales,
    discount_dependency,
    avg_discounted_price,
    avg_full_price,
    avg_rating,
    ROUND((avg_full_price - avg_discounted_price) * discounted_sales / 100, 2) as estimated_margin_loss
FROM product_performance
WHERE discount_dependency > 50
ORDER BY discount_dependency DESC, estimated_margin_loss DESC
LIMIT 15;

-- Revenue Opportunity: Reduce discounts on high-dependency products


-- Q4: Margin Recovery Opportunity Analysis
SELECT 
    category,
    COUNT(*) as discounted_purchases,
    ROUND(SUM(purchase_amount), 2) as discounted_revenue,
    ROUND(SUM(purchase_amount) * 0.15, 2) as estimated_discount_cost,  -- Assuming 15% avg discount
    ROUND(SUM(purchase_amount) * 0.15 * 0.30, 2) as potential_recovery_30pct,  -- 30% reduction in discounts
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
WHERE discount_applied = 'Yes'
GROUP BY category
ORDER BY estimated_discount_cost DESC;

-- Revenue Opportunity: Calculate margin recovery by reducing discount rates


-- Q5: Upsell Opportunity - High frequency, low spend customers
SELECT 
    c.customer_id,
    c.gender,
    c.age_group,
    c.customer_segment,
    COUNT(*) as purchase_frequency,
    ROUND(AVG(c.purchase_amount), 2) as current_avg_purchase,
    ROUND((SELECT AVG(purchase_amount) FROM customers WHERE customer_segment = c.customer_segment), 2) as segment_avg_purchase,
    ROUND((SELECT AVG(purchase_amount) FROM customers WHERE customer_segment = c.customer_segment) - AVG(c.purchase_amount), 2) as upsell_potential,
    c.subscription_status
FROM customers c
GROUP BY c.customer_id, c.gender, c.age_group, c.customer_segment, c.subscription_status
HAVING COUNT(*) >= (SELECT PERCENTILE_CONT(0.60) WITHIN GROUP (ORDER BY COUNT(*)) FROM customers GROUP BY customer_id)
    AND AVG(c.purchase_amount) < (SELECT AVG(purchase_amount) FROM customers WHERE customer_segment = c.customer_segment)
ORDER BY upsell_potential DESC
LIMIT 50;

-- Business Action: Target these customers with premium product recommendations


-- ============================================================================
-- SECTION 3: CUSTOMER CHURN RISK ANALYSIS
-- ============================================================================

-- Q6: At-Risk Customer Identification
WITH customer_behavior AS (
    SELECT 
        customer_id,
        gender,
        age_group,
        customer_segment,
        subscription_status,
        COUNT(*) as recent_purchases,
        ROUND(AVG(purchase_amount), 2) as avg_purchase,
        ROUND(AVG(review_rating), 2) as avg_rating,
        MAX(purchase_amount) as last_purchase_amount,
        SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discount_usage
    FROM customers
    GROUP BY customer_id, gender, age_group, customer_segment, subscription_status
)
SELECT 
    customer_id,
    gender,
    age_group,
    customer_segment,
    subscription_status,
    recent_purchases,
    avg_purchase,
    avg_rating,
    CASE 
        WHEN avg_rating < 3.0 THEN 'High Risk'
        WHEN avg_rating < 3.5 AND recent_purchases <= 2 THEN 'Medium Risk'
        WHEN recent_purchases = 1 AND subscription_status = 'No' THEN 'Medium Risk'
        ELSE 'Low Risk'
    END as churn_risk,
    CASE 
        WHEN avg_rating < 3.0 THEN 'Improve product quality / customer service'
        WHEN recent_purchases <= 2 THEN 'Re-engagement campaign needed'
        WHEN subscription_status = 'No' THEN 'Subscription incentive offer'
        ELSE 'Maintain engagement'
    END as recommended_action
FROM customer_behavior
WHERE customer_segment != 'New Customer'
ORDER BY 
    CASE 
        WHEN avg_rating < 3.0 THEN 1
        WHEN avg_rating < 3.5 AND recent_purchases <= 2 THEN 2
        WHEN recent_purchases = 1 AND subscription_status = 'No' THEN 3
        ELSE 4
    END,
    avg_purchase DESC;

-- Business Action: Proactive retention campaigns


-- ============================================================================
-- SECTION 4: PRODUCT AFFINITY & CROSS-SELL ANALYSIS
-- ============================================================================

-- Q7: Category Combination Analysis (What customers buy together)
WITH customer_categories AS (
    SELECT 
        customer_id,
        GROUP_CONCAT(DISTINCT category ORDER BY category) as category_combination,
        COUNT(DISTINCT category) as num_categories,
        ROUND(SUM(purchase_amount), 2) as total_spent,
        ROUND(AVG(review_rating), 2) as avg_rating
    FROM customers
    GROUP BY customer_id
)
SELECT 
    category_combination,
    COUNT(*) as customer_count,
    ROUND(AVG(total_spent), 2) as avg_customer_value,
    ROUND(SUM(total_spent), 2) as total_revenue,
    ROUND(AVG(avg_rating), 2) as avg_satisfaction,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT customer_id) FROM customers), 2) as percentage_of_customers
FROM customer_categories
WHERE num_categories > 1
GROUP BY category_combination
ORDER BY customer_count DESC
LIMIT 10;

-- Business Action: Bundle products from frequently paired categories


-- Q8: Top Item Pairs within Same Customer (Market Basket)
WITH customer_items AS (
    SELECT 
        customer_id,
        GROUP_CONCAT(DISTINCT item_purchased ORDER BY item_purchased SEPARATOR ', ') as items_bought,
        COUNT(DISTINCT item_purchased) as unique_items,
        ROUND(SUM(purchase_amount), 2) as total_spent
    FROM customers
    GROUP BY customer_id
    HAVING COUNT(DISTINCT item_purchased) > 1
)
SELECT 
    items_bought,
    COUNT(*) as occurrence_count,
    ROUND(AVG(total_spent), 2) as avg_basket_value,
    ROUND(SUM(total_spent), 2) as total_revenue
FROM customer_items
GROUP BY items_bought
ORDER BY occurrence_count DESC
LIMIT 20;

-- Business Action: Create product recommendation engine


-- ============================================================================
-- SECTION 5: SEGMENTATION & TARGETING
-- ============================================================================

-- Q9: High-Value Segment Profiling
WITH segment_profiles AS (
    SELECT 
        customer_segment,
        age_group,
        gender,
        subscription_status,
        COUNT(DISTINCT customer_id) as customer_count,
        ROUND(AVG(purchase_amount), 2) as avg_purchase,
        ROUND(SUM(purchase_amount), 2) as total_revenue,
        ROUND(AVG(review_rating), 2) as avg_rating,
        ROUND(AVG(previous_purchases), 2) as avg_previous_purchases,
        SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discount_users
    FROM customers
    GROUP BY customer_segment, age_group, gender, subscription_status
)
SELECT 
    customer_segment,
    age_group,
    gender,
    subscription_status,
    customer_count,
    avg_purchase,
    total_revenue,
    avg_rating,
    avg_previous_purchases,
    ROUND(discount_users * 100.0 / customer_count, 2) as discount_usage_rate,
    RANK() OVER (PARTITION BY customer_segment ORDER BY total_revenue DESC) as revenue_rank
FROM segment_profiles
WHERE customer_count >= 5
ORDER BY total_revenue DESC;

-- Business Action: Create targeted campaigns by segment characteristics


-- Q10: Subscriber vs Non-Subscriber Deep Dive by Segment
SELECT 
    customer_segment,
    subscription_status,
    COUNT(DISTINCT customer_id) as customer_count,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(SUM(purchase_amount), 2) as segment_revenue,
    ROUND(AVG(review_rating), 2) as avg_rating,
    ROUND(AVG(previous_purchases), 2) as avg_loyalty,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discount_purchases,
    ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as discount_rate
FROM customers
GROUP BY customer_segment, subscription_status
ORDER BY customer_segment, subscription_status;

-- Business Insight: Quantify subscription value by customer segment


-- ============================================================================
-- SECTION 6: SEASONAL & TREND ANALYSIS
-- ============================================================================

-- Q11: Seasonal Performance by Category
SELECT 
    season,
    category,
    COUNT(*) as sales_count,
    ROUND(SUM(purchase_amount), 2) as revenue,
    ROUND(AVG(purchase_amount), 2) as avg_sale,
    ROUND(AVG(review_rating), 2) as avg_rating,
    SUM(CASE WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END) as discounted_sales,
    RANK() OVER (PARTITION BY season ORDER BY SUM(purchase_amount) DESC) as category_rank
FROM customers
GROUP BY season, category
ORDER BY season, revenue DESC;

-- Business Action: Optimize inventory and pricing by season


-- Q12: Size & Color Preferences by Customer Segment
SELECT 
    customer_segment,
    size,
    color,
    COUNT(*) as purchase_count,
    ROUND(AVG(purchase_amount), 2) as avg_purchase,
    ROUND(AVG(review_rating), 2) as avg_rating
FROM customers
GROUP BY customer_segment, size, color
HAVING COUNT(*) >= 10
ORDER BY customer_segment, purchase_count DESC;

-- Business Action: Stock optimization by segment preferences


-- ============================================================================
-- SECTION 7: PROFITABILITY ANALYSIS
-- ============================================================================

-- Q13: Product Profitability Ranking (considering discounts)
SELECT 
    item_purchased,
    category,
    COUNT(*) as units_sold,
    ROUND(SUM(purchase_amount), 2) as gross_revenue,
    ROUND(SUM(CASE WHEN discount_applied = 'Yes' THEN purchase_amount * 0.15 ELSE 0 END), 2) as estimated_discount_cost,
    ROUND(SUM(purchase_amount) - SUM(CASE WHEN discount_applied = 'Yes' THEN purchase_amount * 0.15 ELSE 0 END), 2) as net_revenue,
    ROUND(AVG(review_rating), 2) as avg_rating,
    RANK() OVER (ORDER BY SUM(purchase_amount) - SUM(CASE WHEN discount_applied = 'Yes' THEN purchase_amount * 0.15 ELSE 0 END) DESC) as profitability_rank
FROM customers
GROUP BY item_purchased, category
HAVING COUNT(*) >= 5
ORDER BY net_revenue DESC
LIMIT 20;

-- Business Insight: Focus on most profitable products


-- Q14: Customer Acquisition ROI by Segment
WITH customer_first_purchase AS (
    SELECT 
        customer_id,
        customer_segment,
        MIN(purchase_amount) as first_purchase,
        discount_applied as used_discount_first
    FROM customers
    WHERE previous_purchases = 1
    GROUP BY customer_id, customer_segment, discount_applied
)
SELECT 
    cfp.customer_segment,
    COUNT(*) as new_customers,
    ROUND(AVG(cfp.first_purchase), 2) as avg_first_purchase,
    SUM(CASE WHEN cfp.used_discount_first = 'Yes' THEN 1 ELSE 0 END) as acquired_with_discount,
    ROUND(SUM(CASE WHEN cfp.used_discount_first = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) as discount_acquisition_rate,
    ROUND(AVG(c.purchase_amount), 2) as avg_subsequent_purchase
FROM customer_first_purchase cfp
JOIN customers c ON cfp.customer_id = c.customer_id AND c.previous_purchases > 1
GROUP BY cfp.customer_segment
ORDER BY new_customers DESC;

-- Business Insight: Evaluate discount effectiveness for acquisition


-- ============================================================================
-- SECTION 8: EXECUTIVE SUMMARY QUERIES
-- ============================================================================

-- Q15: Executive Dashboard - Key Metrics
SELECT 
    'Total Revenue' as metric,
    CONCAT('$', FORMAT(SUM(purchase_amount), 2)) as value,
    NULL as vs_target,
    NULL as insight
FROM customers
UNION ALL
SELECT 
    'Average Order Value',
    CONCAT('$', FORMAT(AVG(purchase_amount), 2)),
    NULL,
    'Industry benchmark: $65-75'
FROM customers
UNION ALL
SELECT 
    'Customer Satisfaction',
    CONCAT(FORMAT(AVG(review_rating), 2), '/5.0'),
    NULL,
    CASE 
        WHEN AVG(review_rating) >= 4.0 THEN 'Excellent'
        WHEN AVG(review_rating) >= 3.5 THEN 'Good'
        ELSE 'Needs Improvement'
    END
FROM customers
UNION ALL
SELECT 
    'Subscription Rate',
    CONCAT(FORMAT(SUM(CASE WHEN subscription_status = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2), '%'),
    NULL,
    'Target: 35-40%'
FROM customers
UNION ALL
SELECT 
    'Repeat Customer Rate',
    CONCAT(FORMAT(SUM(CASE WHEN previous_purchases > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(DISTINCT customer_id), 2), '%'),
    NULL,
    'Healthy retention'
FROM customers;

-- ============================================================================
-- ADVANCED QUERIES COMPLETE
-- ============================================================================