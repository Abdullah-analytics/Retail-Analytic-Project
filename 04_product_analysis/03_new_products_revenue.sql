--Q Identify new products introduced in 2010–2011 that generated significant revenue

-- Products that already existed in 2009
WITH FILTER_PRODUCTS_2009 AS (
    SELECT DISTINCT DESCRIPTION AS OLD_PRODUCTS
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE YEARS = 2009
),

-- New products sold in 2010–2011 but not in 2009
NEW_PRODUCT AS (
    SELECT
        T.DESCRIPTION AS NEW_PRODUCTS,
        SUM(T.UNITPRICE * T.QUANTITY) AS TOTAL_REVENUE
    FROM ONLINE_RETAIL_MASTER_TABLE T
    WHERE T.YEARS IN (2010, 2011)

      -- Exclude products that were sold in 2009
      AND NOT EXISTS (
          SELECT OLD_PRODUCTS
          FROM FILTER_PRODUCTS_2009 F
          WHERE F.OLD_PRODUCTS = T.DESCRIPTION
      )
    GROUP BY T.DESCRIPTION
)

-- Show new products ordered by highest revenue
SELECT *
FROM NEW_PRODUCT
ORDER BY TOTAL_REVENUE DESC;



--Q9 Analyze year-over-year changes in total revenue and average order value (AOV)

WITH YEARLY_REVENUE AS (
    -- Calculate total revenue per year
    SELECT
        YEARS,
        SUM(UNITPRICE * QUANTITY) AS TOTAL_REVENUE
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY YEARS
),

YEARLY_ORDERS_COUNT AS (
    -- Count total number of unique orders per year
    SELECT
        YEARS,
        COUNT(DISTINCT INVOICENO) AS TOTAL_ORDERS
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY YEARS
),

YEARLY_AOV AS (
    -- Calculate Average Order Value (AOV) per year
    SELECT
        R.YEARS,
        ROUND((R.TOTAL_REVENUE / O.TOTAL_ORDERS), 2) AS AVERAGE_ORDER_VALUE
    FROM YEARLY_REVENUE R
    LEFT JOIN YEARLY_ORDERS_COUNT O
        ON R.YEARS = O.YEARS
)

-- Final result showing AOV trend by year
SELECT *
FROM YEARLY_AOV
ORDER BY AVERAGE_ORDER_VALUE DESC;
