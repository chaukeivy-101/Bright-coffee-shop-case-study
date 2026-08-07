-- Databricks notebook source
CREATE CATALOG IF NOT EXISTS Bright;

USE CATALOG BRIGHT;
-- Now creating a schema 

Create schema IF NOT EXISTS Coffee_shop;

-- Create or upload flie under schema coffee_shop
----------------------------------------------------------------------------------------------------------
SELECT *
FROM bright.coffee_shop.sales;
-- A. Cleaning data
--1. Check if all columns are in correct format
  --Unit price to be changed from ABC to 123
SELECT 
CAST(REPLACE(unit_price,',','.')AS DOUBLE)AS unit_price
FROM bright.coffee_shop.sales;
--2. Check number of records
SELECT COUNT(*)
FROM bright.coffee_shop.sales;
--3. Check for duplicates
SELECT *, COUNT(*) as duplicate_count
FROM bright.coffee_shop.sales
GROUP BY ALL
HAVING COUNT(*)>1;--No duplicates 
--4. Check for NULL values
SELECT *
FROM bright.coffee_shop.sales
WHERE transaction_id IS NULL OR transaction_date IS NULL OR transaction_time IS NULL OR transaction_qty IS NULL OR store_id IS NULL OR product_id IS NULL OR store_location IS NULL OR unit_price IS NULL OR product_category IS NULL OR product_type IS NULL OR product_detail IS NULL;

-- SILVER (data cleaned now ready to do Analysis)

--B. ANALYSIS OF THE BUSINESS QUESTIONS

-- 1. Total revenue
SELECT
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DOUBLE)) AS Total_revenue
FROM bright.coffee_shop.sales;

SELECT
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales;

-- Total revenue per product category
SELECT
product_category,
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales
GROUP BY product_category;

-- 2. Total revenue per product_category and product_detail
SELECT
product_category,
product_detail,
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales
GROUP BY ALL;


-- 3. Total revenue based on the time of the day
-- Morning : 05:00-11:59
-- Afternoon: 12:00-16:59
-- Evening: 17:00-20:59
-- Night: 21:00-04:59
-- Min/Max time

SELECT
MIN(transaction_time),
MAX(transaction_time)
FROM bright.coffee_shop.sales;

SELECT
CASE
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '05:00:00' AND '11:59:00' THEN 'Morning'
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:00' THEN 'Afternoon'
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '17:00:00' AND '20:59:00' THEN 'Evening'
ELSE 'Night'
END AS time_bucket,
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales
GROUP BY time_bucket;

-- 4.  Total revenue per product_type
SELECT
product_type,
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales
GROUP BY ALL;

-- 5.  Total revenue per store_location
SELECT
store_location,
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales
GROUP BY ALL;

-- 6. Total revenue based per product_category on the time of the day

SELECT
product_category,
CASE
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '05:00:00' AND '11:59:00' THEN 'Morning'
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:00' THEN 'Afternoon'
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '17:00:00' AND '20:59:00' THEN 'Evening'
ELSE 'Night'
END AS time_bucket,
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales
GROUP BY ALL;

-- 7. Date Extraction (Month_name,Month_id and Day_name)
SELECT
transaction_date,
MONTHNAME(transaction_date) AS month_name,
MONTH(transaction_date) AS month_number,
DATE_FORMAT (transaction_date,'yyyy-MMM') AS month_id,
DAYNAME(transaction_date) AS day_name,
DAYOFWEEK(transaction_date) AS day_number
FROM bright.coffee_shop.sales
WHERE MONTHNAME(transaction_date) != 'Jan';

-------------------------------------------------------------------------
SELECT
transaction_date,
MONTHNAME(transaction_date) AS month_name,
MONTH(transaction_date) AS month_number,
DATE_FORMAT (transaction_date,'yyyy-MMM') AS month_id,
DAYNAME(transaction_date) AS day_name,
DAYOFWEEK(transaction_date) AS day_number,
COUNT(transaction_id) AS transaction_count,
COUNT(product_id) AS products_sold,
product_category,
product_detail,
product_type,
store_location,
CASE
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '05:00:00' AND '11:59:00' THEN 'Morning'
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:00' THEN 'Afternoon'
WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '17:00:00' AND '20:59:00' THEN 'Evening'
ELSE 'Night'
END AS time_bucket,
SUM(transaction_qty * CAST(REPLACE(unit_price,',','.')AS DECIMAL(10, 2))) AS Total_revenue
FROM bright.coffee_shop.sales
GROUP BY ALL

-- GOLD (data analysed now ready to do Visualization)