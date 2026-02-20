
-- Are there shifts in peak order times or days of the week between the two datasets?
WITH ORDER_HOURS AS (
    -- Extract hour and day of week, then count unique orders
    SELECT
        YEARS,
        EXTRACT(HOUR FROM INVOICEDATE) AS ORDER_HOUR,
        EXTRACT(DOW FROM INVOICEDATE) AS ORDER_DOW,   -- 0 = Sunday, 6 = Saturday
        COUNT(DISTINCT INVOICENO) AS TOTAL_ORDERS
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY YEARS, ORDER_HOUR, ORDER_DOW
),

HOURLY_TRENDS AS (
    -- Total orders per hour per year
    SELECT
        YEARS,
        ORDER_HOUR,
        SUM(TOTAL_ORDERS) AS ORDERS_PER_HOUR
    FROM ORDER_HOURS
    GROUP BY YEARS, ORDER_HOUR
),

DAILY_TRENDS AS (
    -- Total orders per weekday per year
    SELECT
        YEARS,
        ORDER_DOW,
        SUM(TOTAL_ORDERS) AS ORDERS_PER_DAY
    FROM ORDER_HOURS
    GROUP BY YEARS, ORDER_DOW
)

-- Combine hourly and daily trends for comparison
SELECT
    'HOURLY' AS TREND_TYPE,
    YEARS,
    ORDER_HOUR AS DURATION,
    ORDERS_PER_HOUR AS TOTAL_ORDERS
FROM HOURLY_TRENDS

UNION ALL

SELECT
    'DAILY' AS TREND_TYPE,
    YEARS,
    ORDER_DOW AS DURATION,
    ORDERS_PER_DAY AS TOTAL_ORDERS
FROM DAILY_TRENDS

ORDER BY TREND_TYPE, YEARS, DURATION, TOTAL_ORDERS DESC;
