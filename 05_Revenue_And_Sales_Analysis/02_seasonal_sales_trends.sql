
-- Are there seasonal trends in sales that repeat across both years? (e.g., monthly, weekly, holiday spikes)
WITH MONTHLY_SALES AS (
    -- Aggregate total sales by year and month
    SELECT
        YEARS,
        EXTRACT(MONTH FROM INVOICEDATE) AS MONTHS,
        SUM(UNITPRICE * QUANTITY) AS TOTAL_SALE
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY YEARS, MONTHS
),

WEEKLY_SALES AS (
    -- Aggregate total sales by year and week
    SELECT
        YEARS,
        EXTRACT(WEEK FROM INVOICEDATE) AS WEEKS,
        SUM(UNITPRICE * QUANTITY) AS TOTAL_SALE
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY YEARS, WEEKS
)

-- Combine monthly and weekly trends into one result
SELECT
    'MONTHLY' AS TREND_TYPE,
    YEARS,
    MONTHS AS DURATION,
    TOTAL_SALE
FROM MONTHLY_SALES

UNION ALL

SELECT
    'WEEKLY' AS TREND_TYPE,
    YEARS,
    WEEKS AS DURATION,
    TOTAL_SALE
FROM WEEKLY_SALES

ORDER BY TREND_TYPE, YEARS, DURATION;
