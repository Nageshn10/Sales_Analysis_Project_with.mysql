-- ================================================================
-- Sales Analysis SQL Script
-- Description: Cleans and analyzes the sales dataset
-- Author: Nageshn10
-- ================================================================

-- ================================================================
-- 1️ Check for nulls or duplicates in primary key (CustomerID)
-- A primary key must be unique and not null
-- ================================================================
SELECT 
    CustomerID,
    COUNT(*) AS DuplicateCount
FROM salesmetricsdb.sales
GROUP BY CustomerID
HAVING COUNT(*) > 1;


-- ================================================================
-- 2️ Remove duplicates: Keep 1 row per CustomerID (highest Sales)
-- Using ROW_NUMBER() window function
-- ================================================================
CREATE OR REPLACE TABLE salesmetricsdb.sales_cleaned AS
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY Sales DESC) AS row_num
    FROM salesmetricsdb.sales
) t
WHERE row_num = 1;


-- ================================================================
-- 3️ Trim unwanted spaces in CustomerName
-- ================================================================
UPDATE salesmetricsdb.sales_cleaned
SET CustomerName = TRIM(CustomerName);


-- ================================================================
-- 4️ Top 10 customers by NetSales
-- ================================================================
SELECT 
    CustomerID, 
    CustomerName, 
    NetSales
FROM salesmetricsdb.sales_cleaned
ORDER BY NetSales DESC
LIMIT 10;


-- ================================================================
-- 5️ Customer segmentation based on NetSales
-- High / Medium / Low Value
-- ================================================================
SELECT 
    CustomerID,
    CustomerName,
    CASE
        WHEN NetSales > 200 THEN 'High Value'
        WHEN NetSales BETWEEN 50 AND 200 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerSegment
FROM salesmetricsdb.sales_cleaned;


-- ================================================================
-- 6️ Count of customers in each segment
-- ================================================================
SELECT 
    CustomerSegment, 
    COUNT(*) AS NumCustomers
FROM (
    SELECT 
        CASE
            WHEN NetSales > 200 THEN 'High Value'
            WHEN NetSales BETWEEN 50 AND 200 THEN 'Medium Value'
            ELSE 'Low Value'
        END AS CustomerSegment
    FROM salesmetricsdb.sales_cleaned
) t
GROUP BY CustomerSegment;


-- ================================================================
-- 7️ Discounts analysis: Total discount per customer
-- ================================================================
SELECT 
    CustomerID, 
    CustomerName, 
    SUM(Discount) AS TotalDiscount
FROM salesmetricsdb.sales_cleaned
GROUP BY CustomerID, CustomerName
ORDER BY TotalDiscount DESC
LIMIT 10;


-- ================================================================
-- 8️ Top products by revenue (NetSales)
-- ================================================================
SELECT 
    ProductName, 
    SUM(NetSales) AS TotalRevenue
FROM salesmetricsdb.sales_cleaned
GROUP BY ProductName
ORDER BY TotalRevenue DESC
LIMIT 10;


-- ================================================================
-- 9️ Optional: Check CustomerName for unwanted spaces
-- ================================================================
SELECT CustomerName
FROM salesmetricsdb.sales_cleaned
WHERE CustomerName != TRIM(CustomerName);
