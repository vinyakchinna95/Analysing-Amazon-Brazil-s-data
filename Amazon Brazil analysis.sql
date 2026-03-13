/*
---------------------
   Analysis - I      
---------------------
*/

--Q1
SELECT
    payment_type,
    ROUND(AVG(payment_value))::INTEGER AS rounded_avg_payment
FROM amazon_brazil.payments_data
GROUP BY payment_type
ORDER BY rounded_avg_payment asc;

--Q2
SELECT
    payment_type,
    ROUND(
        COUNT(DISTINCT order_id) * 100.0 /
        (SELECT COUNT(DISTINCT order_id) FROM amazon_brazil.payments_data),
        1
    ) AS percentage_orders
FROM amazon_brazil.payments_data
GROUP BY payment_type
ORDER BY percentage_orders DESC;

--Q3
SELECT p.product_id,o.price
FROM amazon_brazil.product_data p
JOIN amazon_brazil.order_items_data o
ON p.product_id = o.product_id
WHERE o.price BETWEEN 100.00 AND 500.00
AND  p.product_category_name LIKE '%smart%'
ORDER BY o.price DESC;

--Q4
SELECT
    TO_CHAR(o.order_purchase_timestamp, 'Month') AS month_name,
    ROUND(SUM(oi.price))::INTEGER AS total_sales
FROM amazon_brazil.order_data o
JOIN amazon_brazil.order_items_data oi
    ON o.order_id = oi.order_id
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'Month')
ORDER BY total_sales DESC
LIMIT 3;


--Q5
SELECT
    p.product_category_name,
    MAX(oi.price) - MIN(oi.price) AS price_difference 
	FROM amazon_brazil.product_data p
JOIN 
    amazon_brazil.order_items_data oi 
    ON p.product_id = oi.product_id
GROUP BY 
    p.product_category_name
HAVING 
    MAX(oi.price) - MIN(oi.price) > 500.00;



--Q6
SELECT
    payment_type,
    stddev(payment_value) AS std_deviation
FROM amazon_brazil.payments_data
GROUP BY payment_type
ORDER BY std_deviation ASC;

--Q7
SELECT 
    product_id,
    product_category_name
FROM 
   amazon_brazil.product_data
WHERE 
    product_category_name IS NULL
    OR LENGTH(product_category_name) = 1;


/*
---------------------
   Analysis - II        
---------------------
*/

--Q1.	
SELECT 
	CASE
		WHEN oi.price < 200.00 THEN 'low'
		WHEN oi.price BETWEEN 200.00 AND 1000.00 THEN 'medium'
		ELSE 'high'
	END AS order_value_segment,
	p.payment_type,
	COUNT(*) AS count_payment_type
FROM amazon_brazil.order_items_data oi
JOIN amazon_brazil.payments_data p ON oi.order_id = p.order_id
GROUP BY order_value_segment,p.payment_type
ORDER BY count_payment_type DESC;

--Q2.	
SELECT
    p.product_category_name,
    MIN(oi.price) AS min_price,
    MAX(oi.price) AS max_price,
    AVG(oi.price) AS avg_price
FROM amazon_brazil.product_data p
JOIN amazon_brazil.order_items_data oi
    ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY avg_price DESC;	

--Q3.	
SELECT 
    cu.customer_unique_id,
    COUNT(o.order_id) AS total_orders
FROM amazon_brazil.customer_data cu
JOIN amazon_brazil.order_data o 
    ON cu.customer_id = o.customer_id
GROUP BY cu.customer_unique_id
HAVING COUNT(o.order_id) > 1;

--Q4.	
DROP TABLE IF EXISTS customer_categories;
CREATE TEMPORARY TABLE customer_categories AS
SELECT  
    cu.customer_unique_id,
    CASE
        WHEN COUNT(o.order_id) = 1 THEN 'New'
        WHEN COUNT(o.order_id) BETWEEN 2 AND 4 THEN 'Returning'
        ELSE 'Loyal'
    END AS customer_type
FROM amazon_brazil.customer_data cu
JOIN amazon_brazil.order_data o
    ON cu.customer_id = o.customer_id
GROUP BY cu.customer_unique_id;

SELECT customer_unique_id, customer_type
FROM customer_categories;

--Q5.	
SELECT 
	p.product_category_name,
	SUM(oi.price + oi.freight_value) AS total_revenue
FROM amazon_brazil.product_data p
JOIN amazon_brazil.order_items_data oi
ON p.product_id = oi.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 5;



/*
---------------------
   Analysis - III       
---------------------
*/

--Q1.	
SELECT
    season,
    SUM(total_sales) AS total_sales
FROM (
    SELECT
        CASE
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (3, 4, 5) THEN 'Spring'
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (6, 7, 8) THEN 'Summer'
            WHEN EXTRACT(MONTH FROM o.order_purchase_timestamp) IN (9, 10, 11) THEN 'Autumn'
            ELSE 'Winter'
        END AS season,
        oi.price AS total_sales
    FROM amazon_brazil.order_items_data oi
    JOIN amazon_brazil.order_data o
        ON oi.order_id = o.order_id
) t
GROUP BY season;
--Q2.	
SELECT
    product_id,
    COUNT(*) AS total_quantity_sold
FROM amazon_brazil.order_items_data
GROUP BY product_id
HAVING COUNT(*) >
       (SELECT AVG(cnt)
        FROM (
            SELECT COUNT(*) AS cnt
            FROM amazon_brazil.order_items_data
            GROUP BY product_id
        ) t);
--Q3.	
SELECT
    TO_CHAR(o.order_purchase_timestamp, 'Month') AS month_name,
    SUM(oi.price + oi.freight_value) AS total_revenue
FROM amazon_brazil.order_data o
JOIN amazon_brazil.order_items_data oi
    ON o.order_id = oi.order_id
WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
GROUP BY TO_CHAR(o.order_purchase_timestamp, 'Month')
ORDER BY total_revenue ASC;

--Sales can be analyzed at different time levels such as year, month, week, or day by extracting the required part from a timestamp column. The aggregation logic remains the same; only the time-based grouping changes. This approach helps identify trends and patterns across different time periods.
                    




--Q4.	
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM amazon_brazil.order_data
    GROUP BY customer_id
),
customer_segments AS (
    SELECT
        customer_id,
        CASE
            WHEN order_count BETWEEN 1 AND 2 THEN 'Occasional'
            WHEN order_count BETWEEN 3 AND 5 THEN 'Regular'
            ELSE 'Loyal'
        END AS customer_type
    FROM customer_orders
)
SELECT
    customer_type,
    COUNT(*) AS count
FROM customer_segments
GROUP BY customer_type;

 

--Q5.	
SELECT
    customer_id,
    avg_order_value,
    RANK() OVER (ORDER BY avg_order_value DESC) AS customer_rank
FROM (
    SELECT
        o.customer_id,
        ROUND(AVG(oi.price),0) AS avg_order_value
    FROM amazon_brazil.order_data o
    JOIN amazon_brazil.order_items_data oi
        ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) t
ORDER BY customer_rank
LIMIT 20;

--Q6.	
SELECT * FROM amazon_brazil.order_items_data;

WITH RECURSIVE monthly_sales AS (
    SELECT
        oi.product_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)::date AS sales_month,
        SUM(oi.price) AS monthly_sales
    FROM amazon_brazil.order_items_data oi
    JOIN amazon_brazil.order_data o
        ON oi.order_id = o.order_id
    GROUP BY
        oi.product_id,
        DATE_TRUNC('month', o.order_purchase_timestamp)
),
recursive_sales AS (
    -- Anchor: first month per product
    SELECT
        product_id,
        sales_month,
        monthly_sales,
        monthly_sales AS cumulative_sales
    FROM monthly_sales ms
    WHERE sales_month = (
        SELECT MIN(ms2.sales_month)
        FROM monthly_sales ms2
        WHERE ms2.product_id = ms.product_id
    )
    UNION ALL
  -- Recursive step: next month
    SELECT
        ms.product_id,
        ms.sales_month,
        ms.monthly_sales,
        rs.cumulative_sales + ms.monthly_sales AS cumulative_sales
    FROM recursive_sales rs
    JOIN monthly_sales ms
      ON ms.product_id = rs.product_id
     AND ms.sales_month = rs.sales_month + INTERVAL '1 month'
)
SELECT
    product_id,
    sales_month,
    cumulative_sales
FROM recursive_sales
ORDER BY product_id, sales_month;

--Q7.
WITH monthly_sales AS (
    SELECT 
        op.payment_type,
        EXTRACT(MONTH FROM o.order_purchase_timestamp) AS sale_month,
        SUM(oi.price) AS monthly_total
    FROM amazon_brazil.order_data o
    JOIN amazon_brazil.order_items_data oi ON o.order_id = oi.order_id
    JOIN amazon_brazil.payments_data op ON o.order_id = op.order_id
    WHERE EXTRACT(YEAR FROM o.order_purchase_timestamp) = 2018
    GROUP BY op.payment_type, EXTRACT(MONTH FROM o.order_purchase_timestamp)
)
SELECT 
    payment_type,
    sale_month,
    monthly_total,
    ROUND(
        (monthly_total - LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month)) * 100.0 /
		NULLIF(LAG(monthly_total) OVER (PARTITION BY payment_type ORDER BY sale_month), 0), 2) 
	AS monthly_change
FROM monthly_sales
ORDER BY payment_type, sale_month;






