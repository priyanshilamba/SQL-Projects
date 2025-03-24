CREATE DATABASE Retail_Promotion_Impact;
USE Retail_Promotion_Impact;

CREATE TABLE cpi_data (
    Date date,
    cpi FLOAT
);

CREATE TABLE mall_customers (
    customer_id INT PRIMARY KEY,
    gender VARCHAR(10),
    age INT,
    annual_income FLOAT,
    spending_score FLOAT
);

CREATE TABLE online_retail (
    invoice_no VARCHAR(20),
    stock_code VARCHAR(20),
    description TEXT,
    quantity INT,
    invoice_date DATETIME,
    unit_price FLOAT,
    customer_id INT,
    country VARCHAR(50)
);

CREATE TABLE store_sales (
    store_id INT,
    dept INT,
    date DATE,
    weekly_sales FLOAT,
    isholiday TEXT
);


CREATE TABLE stores (
    store_id INT PRIMARY KEY,
    store_type CHAR(1),
    store_size FLOAT
);

SHOW TABLES;


-- What is the total number of stores, and how many stores are of each type (A, B, C)?
SELECT store_type, COUNT(*) AS store_count
FROM stores
GROUP BY store_type;

-- What is the average store size for each store type?
SELECT store_type, AVG(store_size) AS avg_store_size
FROM stores
GROUP BY store_type;

-- Which store has the largest size, and what type is it?
SELECT store_id, store_type, store_size
FROM stores
ORDER BY store_size DESC
LIMIT 1;

-- What is the average age and spending score of customers, broken down by gender?
SELECT gender, AVG(age) AS avg_age, AVG(spending_score) AS avg_spending_score
FROM mall_customers
GROUP BY gender;


-- Identify the top 5 customers with the highest annual income. List their customer IDs and incomes.
SELECT customer_id, annual_income
FROM mall_customers
ORDER BY annual_income DESC
LIMIT 5;

-- Segment customers into age groups (e.g., 18-25, 26-35, 36-45, etc.) and calculate the average spending score for each group.
SELECT 
    CASE 
        WHEN age BETWEEN 18 AND 25 THEN '18-25'
        WHEN age BETWEEN 26 AND 35 THEN '26-35'
        WHEN age BETWEEN 36 AND 45 THEN '36-45'
        WHEN age BETWEEN 46 AND 55 THEN '46-55'
        ELSE '56+'
    END AS age_group,
    AVG(spending_score) AS avg_spending_score
FROM mall_customers
GROUP BY age_group;

-- What is the rolling 4-week average sales for each store over time, and how does it help in identifying sales trends?
SELECT store_id, date, 
       AVG(weekly_sales) OVER (PARTITION BY store_id ORDER BY date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS rolling_4_week_sales
FROM store_sales; 

-- How do stores rank based on their total sales performance?
SELECT store_id, SUM(weekly_sales) AS total_sales,
       RANK() OVER (ORDER BY SUM(weekly_sales) DESC) AS sales_rank
FROM store_sales
GROUP BY store_id; -- changed

-- Calculate the year-over-year percentage change in CPI.
SELECT cpi_data.date, 
       (cpi - LAG(cpi) OVER (ORDER BY cpi_data.date)) * 100.0 / LAG(cpi) OVER (ORDER BY cpi_data.date) AS yoy_cpi_change
FROM cpi_data;

-- Which departments have the highest average weekly sales?
SELECT dept, AVG(weekly_sales) AS avg_weekly_sales
FROM store_sales
GROUP BY dept
ORDER BY avg_weekly_sales DESC; 

-- What is the year-over-year percentage change in total sales for each year?
SELECT YEAR(date) AS sales_year, 
       SUM(weekly_sales) AS total_sales, 
       (SUM(weekly_sales) - LAG(SUM(weekly_sales)) OVER (ORDER BY YEAR(date))) / 
       LAG(SUM(weekly_sales)) OVER (ORDER BY YEAR(date)) * 100 AS yoy_sales_change
FROM store_sales
GROUP BY YEAR(date); 

-- What is the rolling 4-week average sales for each store over time?
SELECT store_id, date, 
       AVG(weekly_sales) OVER (PARTITION BY store_id ORDER BY date ROWS BETWEEN 3 PRECEDING AND CURRENT ROW) AS rolling_4_week_sales
FROM store_sales; 

-- How does the average weekly sales differ between holiday and non-holiday periods?
SELECT isholiday, AVG(weekly_sales) AS avg_weekly_sales
FROM store_sales
GROUP BY isholiday; 

-- Rank stores by their size within their respective store type (A, B, C). 
-- Use a window function to assign a rank to each store.
SELECT store_id, store_type, store_size,
       RANK() OVER (PARTITION BY store_type ORDER BY store_size DESC) AS store_rank
FROM stores;

-- How do stores rank based on their total sales?
SELECT store_id, SUM(weekly_sales) AS total_sales,
       RANK() OVER (ORDER BY SUM(weekly_sales) DESC) AS sales_rank
FROM store_sales
GROUP BY store_id;

-- Which stores experienced the highest percentage increase in sales
--  during promotional periods compared to non-promotional periods?
WITH promo_sales AS (
    SELECT store_id, 
           SUM(CASE WHEN isholiday = 'True' THEN weekly_sales ELSE 0 END) AS total_promo_sales,
           SUM(CASE WHEN isholiday = 'False' THEN weekly_sales ELSE 0 END) AS total_non_promo_sales
    FROM store_sales
    GROUP BY store_id
)
SELECT store_id, 
       (total_promo_sales - total_non_promo_sales) * 100.0 / total_non_promo_sales AS promo_sales_increase_pct
FROM promo_sales
ORDER BY promo_sales_increase_pct DESC
LIMIT 5; 
