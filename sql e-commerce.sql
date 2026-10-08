-- E-Commerce Power BI Project - SQL Analysis
-- MySQL 8.0
-- IMPORTANT: This SQL file matches the columns shown in the user's Excel data exactly.

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- =========================================================
-- 1. TABLE WITH THE EXACT POWER BI / EXCEL COLUMNS
-- =========================================================

DROP TABLE IF EXISTS ecommerce_sales;

CREATE TABLE ecommerce_sales (
    Order_ID VARCHAR(30),
    Order_Date DATE,
    Customer_Name VARCHAR(150),
    Product_Name VARCHAR(150),
    Category VARCHAR(100),
    Region VARCHAR(50),
    City VARCHAR(100),
    Customer_Segment VARCHAR(50),
    Sales DECIMAL(16,2),
    Profit DECIMAL(16,2),
    Discount DECIMAL(6,4),
    Rating DECIMAL(3,1)
);

-- Exact columns:
-- Order_ID
-- Order_Date
-- Customer_Name
-- Product_Name
-- Category
-- Region
-- City
-- Customer_Segment
-- Sales
-- Profit
-- Discount
-- Rating

-- =========================================================
-- 2. LOAD CSV DATA
-- =========================================================
-- Your Excel screenshot shows dates such as 07-12-2024.
-- If your CSV stores dates as DD-MM-YYYY, use this import pattern:
--
-- LOAD DATA LOCAL INFILE 'C:/path/ecommerce_clean_data.csv'
-- INTO TABLE ecommerce_sales
-- FIELDS TERMINATED BY ','
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 ROWS
-- (Order_ID, @Order_Date, Customer_Name, Product_Name, Category,
--  Region, City, Customer_Segment, Sales, Profit, Discount, Rating)
-- SET Order_Date = STR_TO_DATE(@Order_Date, '%d-%m-%Y');

-- =========================================================
-- 3. BASIC DATA CHECKS
-- =========================================================

SELECT COUNT(*) AS Total_Rows
FROM ecommerce_sales;

SELECT COUNT(DISTINCT Order_ID) AS Total_Orders
FROM ecommerce_sales;

SELECT COUNT(DISTINCT Customer_Name) AS Total_Customers
FROM ecommerce_sales;

SELECT COUNT(DISTINCT Product_Name) AS Total_Products
FROM ecommerce_sales;

SELECT COUNT(DISTINCT Category) AS Total_Categories
FROM ecommerce_sales;

SELECT COUNT(DISTINCT Region) AS Total_Regions
FROM ecommerce_sales;

-- =========================================================
-- 4. CHECK NULL / MISSING VALUES
-- =========================================================

SELECT
    SUM(Order_ID IS NULL OR TRIM(Order_ID) = '') AS Missing_Order_ID,
    SUM(Order_Date IS NULL) AS Missing_Order_Date,
    SUM(Customer_Name IS NULL OR TRIM(Customer_Name) = '') AS Missing_Customer_Name,
    SUM(Product_Name IS NULL OR TRIM(Product_Name) = '') AS Missing_Product_Name,
    SUM(Category IS NULL OR TRIM(Category) = '') AS Missing_Category,
    SUM(Region IS NULL OR TRIM(Region) = '') AS Missing_Region,
    SUM(City IS NULL OR TRIM(City) = '') AS Missing_City,
    SUM(Customer_Segment IS NULL OR TRIM(Customer_Segment) = '') AS Missing_Customer_Segment,
    SUM(Sales IS NULL) AS Missing_Sales,
    SUM(Profit IS NULL) AS Missing_Profit,
    SUM(Discount IS NULL) AS Missing_Discount,
    SUM(Rating IS NULL) AS Missing_Rating
FROM ecommerce_sales;

-- =========================================================
-- 5. DATA CLEANING
-- =========================================================

-- Find names with leading/trailing spaces
SELECT
    Order_ID,
    Customer_Name
FROM ecommerce_sales
WHERE Customer_Name <> TRIM(Customer_Name);

-- Find products with leading/trailing spaces
SELECT
    Order_ID,
    Product_Name
FROM ecommerce_sales
WHERE Product_Name <> TRIM(Product_Name);

-- Find duplicate Order_IDs
SELECT
    Order_ID,
    COUNT(*) AS Duplicate_Count
FROM ecommerce_sales
GROUP BY Order_ID
HAVING COUNT(*) > 1;

-- Check invalid negative values
SELECT *
FROM ecommerce_sales
WHERE Sales < 0
   OR Profit < 0
   OR Discount < 0
   OR Rating < 0;

-- Check discount range
SELECT *
FROM ecommerce_sales
WHERE Discount > 1;

-- Check rating range
SELECT *
FROM ecommerce_sales
WHERE Rating < 1 OR Rating > 5;

-- =========================================================
-- 6. CLEANED VIEW
-- =========================================================

CREATE OR REPLACE VIEW vw_ecommerce_clean AS
SELECT
    TRIM(Order_ID) AS Order_ID,
    Order_Date,
    TRIM(Customer_Name) AS Customer_Name,
    TRIM(Product_Name) AS Product_Name,
    TRIM(Category) AS Category,
    TRIM(Region) AS Region,
    TRIM(City) AS City,
    TRIM(Customer_Segment) AS Customer_Segment,
    Sales,
    Profit,
    Discount,
    Rating
FROM ecommerce_sales;

-- =========================================================
-- 7. MAIN KPI ANALYSIS
-- =========================================================

SELECT
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Customer_Name) AS Total_Customers,
    COUNT(DISTINCT Product_Name) AS Total_Products,
    SUM(Sales) / NULLIF(COUNT(DISTINCT Order_ID), 0) AS Average_Order_Value
FROM vw_ecommerce_clean;

-- Profit margin
SELECT
    ROUND(
        SUM(Profit) / NULLIF(SUM(Sales), 0) * 100,
        2
    ) AS Profit_Margin_Percent
FROM vw_ecommerce_clean;

-- Average rating
SELECT
    ROUND(AVG(Rating), 2) AS Average_Rating
FROM vw_ecommerce_clean
WHERE Rating IS NOT NULL;

-- Average discount
SELECT
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent
FROM vw_ecommerce_clean;

-- =========================================================
-- 8. SALES ANALYSIS
-- =========================================================

-- Sales by month
SELECT
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY YEAR(Order_Date), MONTH(Order_Date)
ORDER BY Year, Month;

-- Sales by category
SELECT
    Category,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Sales by region
SELECT
    Region,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Region
ORDER BY Total_Sales DESC;

-- Sales by city
SELECT
    City,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY City
ORDER BY Total_Sales DESC;

-- Sales by customer segment
SELECT
    Customer_Segment,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Customer_Segment
ORDER BY Total_Sales DESC;

-- =========================================================
-- 9. PROFIT ANALYSIS
-- =========================================================

-- Profit by category
SELECT
    Category,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Category
ORDER BY Total_Profit DESC;

-- Profit by region
SELECT
    Region,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Region
ORDER BY Total_Profit DESC;

-- Profit by city
SELECT
    City,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY City
ORDER BY Total_Profit DESC;

-- Profit by product
SELECT
    Product_Name,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Product_Name
ORDER BY Total_Profit DESC;

-- =========================================================
-- 10. TOP 10 PRODUCTS
-- =========================================================

-- Top 10 products by sales
SELECT
    Product_Name,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- Top 10 products by profit
SELECT
    Product_Name,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Product_Name
ORDER BY Total_Profit DESC
LIMIT 10;

-- Bottom 10 products by sales
SELECT
    Product_Name,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Product_Name
ORDER BY Total_Sales ASC
LIMIT 10;

-- =========================================================
-- 11. CUSTOMER ANALYSIS
-- =========================================================

-- Top 10 customers by sales
SELECT
    Customer_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Customer_Name
ORDER BY Total_Sales DESC
LIMIT 10;

-- Customer segment analysis
SELECT
    Customer_Segment,
    COUNT(DISTINCT Customer_Name) AS Customers,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM vw_ecommerce_clean
GROUP BY Customer_Segment
ORDER BY Sales DESC;

-- =========================================================
-- 12. REGION ANALYSIS
-- =========================================================

SELECT
    Region,
    COUNT(DISTINCT Order_ID) AS Orders,
    COUNT(DISTINCT Customer_Name) AS Customers,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit,
    ROUND(SUM(Profit) / NULLIF(SUM(Sales),0) * 100, 2) AS Profit_Margin_Percent
FROM vw_ecommerce_clean
GROUP BY Region
ORDER BY Sales DESC;

-- =========================================================
-- 13. DISCOUNT ANALYSIS
-- =========================================================

SELECT
    Category,
    ROUND(AVG(Discount) * 100, 2) AS Average_Discount_Percent,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Category
ORDER BY Total_Sales DESC;

-- Discount vs profit
SELECT
    CASE
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.10 THEN '1-10%'
        WHEN Discount <= 0.20 THEN '11-20%'
        WHEN Discount <= 0.30 THEN '21-30%'
        ELSE 'Above 30%'
    END AS Discount_Band,
    COUNT(DISTINCT Order_ID) AS Orders,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM vw_ecommerce_clean
GROUP BY Discount_Band
ORDER BY Sales DESC;

-- =========================================================
-- 14. RATING ANALYSIS
-- =========================================================

SELECT
    Rating,
    COUNT(*) AS Order_Count,
    SUM(Sales) AS Sales,
    SUM(Profit) AS Profit
FROM vw_ecommerce_clean
WHERE Rating IS NOT NULL
GROUP BY Rating
ORDER BY Rating DESC;

SELECT
    Category,
    ROUND(AVG(Rating), 2) AS Average_Rating
FROM vw_ecommerce_clean
WHERE Rating IS NOT NULL
GROUP BY Category
ORDER BY Average_Rating DESC;

-- =========================================================
-- 15. BUSINESS QUESTIONS
-- =========================================================

-- Highest-sales category
SELECT
    Category,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Category
ORDER BY Total_Sales DESC
LIMIT 1;

-- Highest-profit region
SELECT
    Region,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Region
ORDER BY Total_Profit DESC
LIMIT 1;

-- Highest-sales city
SELECT
    City,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY City
ORDER BY Total_Sales DESC
LIMIT 1;

-- Highest-sales product
SELECT
    Product_Name,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Product_Name
ORDER BY Total_Sales DESC
LIMIT 1;

-- Highest-profit product
SELECT
    Product_Name,
    SUM(Profit) AS Total_Profit
FROM vw_ecommerce_clean
GROUP BY Product_Name
ORDER BY Total_Profit DESC
LIMIT 1;

-- Best customer segment by sales
SELECT
    Customer_Segment,
    SUM(Sales) AS Total_Sales
FROM vw_ecommerce_clean
GROUP BY Customer_Segment
ORDER BY Total_Sales DESC
LIMIT 1;

-- =========================================================
-- 16. WINDOW FUNCTION - PRODUCT RANKING
-- =========================================================

SELECT
    Product_Name,
    SUM(Sales) AS Total_Sales,
    DENSE_RANK() OVER (
        ORDER BY SUM(Sales) DESC
    ) AS Sales_Rank
FROM vw_ecommerce_clean
GROUP BY Product_Name;

-- =========================================================
-- 17. TOP 3 PRODUCTS WITHIN EACH CATEGORY
-- =========================================================

WITH ProductSales AS (
    SELECT
        Category,
        Product_Name,
        SUM(Sales) AS Total_Sales
    FROM vw_ecommerce_clean
    GROUP BY Category, Product_Name
),
RankedProducts AS (
    SELECT
        Category,
        Product_Name,
        Total_Sales,
        DENSE_RANK() OVER (
            PARTITION BY Category
            ORDER BY Total_Sales DESC
        ) AS Product_Rank
    FROM ProductSales
)
SELECT
    Category,
    Product_Name,
    Total_Sales,
    Product_Rank
FROM RankedProducts
WHERE Product_Rank <= 3
ORDER BY Category, Product_Rank;

-- =========================================================
-- 18. MONTH-OVER-MONTH SALES
-- =========================================================

WITH MonthlySales AS (
    SELECT
        DATE_FORMAT(Order_Date, '%Y-%m') AS Sales_Month,
        SUM(Sales) AS Total_Sales
    FROM vw_ecommerce_clean
    GROUP BY DATE_FORMAT(Order_Date, '%Y-%m')
)
SELECT
    Sales_Month,
    Total_Sales,
    LAG(Total_Sales) OVER (
        ORDER BY Sales_Month
    ) AS Previous_Month_Sales,
    ROUND(
        (
            Total_Sales -
            LAG(Total_Sales) OVER (ORDER BY Sales_Month)
        )
        / NULLIF(
            LAG(Total_Sales) OVER (ORDER BY Sales_Month),
            0
        ) * 100,
        2
    ) AS MoM_Growth_Percent
FROM MonthlySales
ORDER BY Sales_Month;

-- =========================================================
-- END
-- =========================================================
