SELECT * FROM coffeeshopanalysis.coffee_shop_sales;

-- remove duplicates
DELETE FROM coffeeshopanalysis.coffee_shop_sales
WHERE transaction_id IN (
    SELECT transaction_id
    FROM (
        SELECT transaction_id, COUNT(*) AS count
        FROM coffeeshopanalysis.coffee_shop_sales
        GROUP BY transaction_id
        HAVING count > 1
    ) AS duplicates
);

-- remove rows with null in transaction id, unit price or store id
DELETE FROM coffeeshopanalysis.coffee_shop_sales
WHERE transaction_qty IS NULL
   OR unit_price IS NULL
   OR store_id IS NULL;
   
-- Convert transaction_date and transaction_time to Date Format and time format respectively:
-- Step 1: Convert text to date format
UPDATE coffeeshopanalysis.coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%m/%d/%Y');
-- Step 2: Alter the column type to DATE
ALTER TABLE coffeeshopanalysis.coffee_shop_sales
MODIFY transaction_date DATE;

-- Step 1: Convert text to time format
UPDATE coffeeshopanalysis.coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s');
-- Step 2: Alter the column type to TIME
ALTER TABLE coffeeshopanalysis.coffee_shop_sales
MODIFY transaction_time TIME;

-- total revenue calculation
SELECT *,
   (unit_price * transaction_qty) AS total_revenue
FROM coffeeshopanalysis.coffee_shop_sales;

-- Overall revenue and transaction
SELECT 
    SUM(unit_price * transaction_qty) AS total_revenue,
    COUNT(transaction_id) AS total_transactions
FROM coffeeshopanalysis.coffee_shop_sales;


-- Store Performance Analysis
-- Revenue per Store:
SELECT store_id, 
       store_location, 
       SUM(unit_price * transaction_qty) AS total_store_revenue,
       COUNT(transaction_id) AS total_transactions
FROM coffeeshopanalysis.coffee_shop_sales
GROUP BY store_id, store_location
ORDER BY total_store_revenue DESC;

-- Product Performance Analysis
-- Best-Selling Products: Identify the top 10 best-selling products by transaction quantity and revenue.
SELECT product_id, product_category, product_type, product_detail,
       SUM(transaction_qty) AS total_quantity_sold,
       SUM(unit_price * transaction_qty) AS total_product_revenue
FROM coffeeshopanalysis.coffee_shop_sales
GROUP BY product_id, product_category, product_type, product_detail
ORDER BY total_quantity_sold DESC
LIMIT 10;


-- Revenue by Product Category: Analyze which product categories generate the most revenue.
SELECT product_category, 
       SUM(unit_price * transaction_qty) AS category_revenue
FROM coffeeshopanalysis.coffee_shop_sales
GROUP BY product_category
ORDER BY category_revenue DESC;

-- TIME BASED ANALYSIS
-- Sales by Hour of the Day: Find out the peak hours for transactions.
SELECT HOUR(transaction_time) AS hour_of_day, 
       SUM(transaction_qty) AS total_sales_volume,
       SUM(unit_price * transaction_qty) AS total_revenue
FROM coffeeshopanalysis.coffee_shop_sales
GROUP BY hour_of_day
ORDER BY hour_of_day;
-- done

-- Sales by Day of the Week: Identify which days of the week are busiest.
SELECT DAYOFWEEK(transaction_date) AS day_of_week, 
       SUM(transaction_qty) AS total_sales_volume,
       SUM(unit_price * transaction_qty) AS total_revenue
FROM coffeeshopanalysis.coffee_shop_sales
GROUP BY day_of_week
ORDER BY day_of_week;

-- Monthly Sales Trends: Analyze sales by month to find seasonal trends.
SELECT MONTH(transaction_date) AS month, 
       SUM(transaction_qty) AS total_sales_volume,
       SUM(unit_price * transaction_qty) AS total_revenue
FROM coffeeshopanalysis.coffee_shop_sales
GROUP BY month
ORDER BY month;

-- Customer Behavior Insights
-- Popular Products at Different Times of the Day:
SELECT product_category, 
       HOUR(transaction_time) AS hour_of_day, 
       SUM(transaction_qty) AS total_sales_volume
FROM coffeeshopanalysis.coffee_shop_sales
GROUP BY product_category, hour_of_day
ORDER BY total_sales_volume DESC;
