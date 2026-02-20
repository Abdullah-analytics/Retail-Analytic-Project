--Q Identify customers who increased their spending the most between 2009 and 2010
WITH CUSTOMERS_SPENDING AS (
    -- Calculate total spending per customer per year
    SELECT
        CUSTOMERID,
        YEARS,
        SUM(QUANTITY * UNITPRICE) AS TOTAL_SPEND
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY CUSTOMERID, YEARS
),

TOTAL_SPENDINGS AS (
    -- Combine spending into two columns: 2009 vs 2010
    SELECT
        CUSTOMERID,
        SUM(CASE WHEN YEARS = 2009 THEN TOTAL_SPEND END) AS SPEND_2009,
        SUM(CASE WHEN YEARS = 2010 THEN TOTAL_SPEND END) AS SPEND_2010
    FROM CUSTOMERS_SPENDING
    GROUP BY CUSTOMERID
),

INCREASING_SPEND AS (
    -- Calculate spending difference per customer
    SELECT
        CUSTOMERID,
        SPEND_2009,
        SPEND_2010,
        (SPEND_2010 - SPEND_2009) AS INCREASING_AMOUNT  -- Positive: increased, Negative: decreased
    FROM TOTAL_SPENDINGS
    WHERE SPEND_2009 IS NOT NULL
      AND SPEND_2010 IS NOT NULL
)

-- Show all customers sorted by highest spending increase
SELECT *
FROM INCREASING_SPEND
ORDER BY INCREASING_AMOUNT DESC;
