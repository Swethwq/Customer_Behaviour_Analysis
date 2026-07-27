use customer_behaviour;

-- Male v/s Female Total Revenue 
SELECT gender, SUM(purchase_amount) as revenue
from mytable
group by gender;

-- Which customer used discount and still purchase more than average purchase_amount?
SELECT customer_id, purchase_amount
FROM mytable
WHERE discount_applied = 'Yes' 
  AND purchase_amount >= (SELECT AVG(purchase_amount) FROM mytable);
  
-- Top 5 products with highest average review rating
SELECT item_purchased, ROUND(AVG(review_rating),2) as "Average Product Rating"
FROM mytable
GROUP BY item_purchased
ORDER BY AVG(review_rating) DESC
LIMIT 5;

-- Compare the average Purchase Amounts b/w Standard and Express Shipping.
SELECT shipping_type, 
ROUND(AVG(purchase_amount),2)
FROM mytable
WHERE shipping_type in ('Standard', 'Express')
GROUP BY shipping_type;

-- Average spend and total revenue of subscriber and non-subscriber
SELECT subscription_status,
COUNT(customer_id) as total_customers,
ROUND(AVG(purchase_amount),2) as avg_spend,
ROUND(SUM(purchase_amount),2) as total_revenue
FROM mytable
GROUP BY subscription_status
ORDER BY total_revenue , avg_spend desc;

-- Give top 5 product with highest percentage of purchases when discount is applied
SELECT item_purchased,
ROUND(SUM(case WHEN discount_applied = 'Yes' THEN 1 ELSE 0 END)/COUNT(*) * 100,2) as discount_rate
FROM mytable
GROUP BY item_purchased
ORDER BY discount_rate DESC
LIMIT 5;

-- Segment Customer based on New, Returning, Loyal
WITH customer_type as (
SELECT customer_id, previous_purchases,
CASE
	WHEN previous_purchases = 1 THEN 'New'
    WHEN previous_purchases BETWEEN 2 AND 10 THEN 'Returning'
    ELSE 'Loyal'
    END AS customer_segment
FROM mytable
)

SELECT customer_segment, count(*) as 'Number of Customers'
FROM customer_type
GROUP BY customer_segment;

-- TOP 3 purchase product in each category
WITH item_counts as(
SELECT category,
item_purchased,
COUNT(customer_id) as total_orders,
ROW_NUMBER() over(partition by category order by count(customer_id) DESC) as item_rank
FROM mytable
GROUP BY category, item_purchased
)

SELECT item_rank, category, item_purchased, total_orders
FROM item_counts
WHERE item_rank <= 3;

-- ARE customer who are repeat buyer more likely to subscribe?
SELECT subscription_status,
COUNT(customer_id) as repeat_buyers
FROM mytable
WHERE previous_purchases > 5
GROUP BY subscription_status;

-- The revenue contribution of each age group
SELECT age_group,
SUM(purchase_amount) as total_revenue
FROM mytable
group by age_group
order by total_revenue desc;
