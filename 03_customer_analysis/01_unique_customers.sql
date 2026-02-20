--How has the number of unique customers changed year-over-year?

-- Calculate total orders per customer for 2009 and 2010
WITH CUSTOMER_ORDERS AS (
    SELECT 
        CUSTOMERID,

        -- Count distinct invoices for year 2009
        COUNT(DISTINCT CASE 
            WHEN YEARS = 2009 THEN INVOICENO 
        END) AS TOTAL_ORDERS_2009,

        -- Count distinct invoices for year 2010
        COUNT(DISTINCT CASE 
            WHEN YEARS = 2010 THEN INVOICENO 
        END) AS TOTAL_ORDERS_2010

    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE YEARS IN (2009, 2010)   -- filter only required years
    GROUP BY CUSTOMERID
)
-- Final result: customers who ordered in both years
SELECT 
    CUSTOMERID,
    TOTAL_ORDERS_2009,
    TOTAL_ORDERS_2010
FROM CUSTOMER_ORDERS
WHERE TOTAL_ORDERS_2009 > 0
  AND TOTAL_ORDERS_2010 > 0
ORDER BY CUSTOMERID;


-- How many orders were cancelled each year, year-over-year?
SELECT YEARS,
COUNT(*) FROM ONLINE_RETAIL_MASTER_TABLE
WHERE INVOICENO LIKE 'C%'  -- cancelled ivoices start with 'C'
GROUP BY YEARS
ORDER BY YEARS ASC


