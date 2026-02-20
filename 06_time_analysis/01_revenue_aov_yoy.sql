
-- How has the total revenue and average order value changed year-over-year?

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

