--Q Identify products with increasing or decreasing trends in sales quantity between 2009 and 2010
WITH PRODUCT_YEARLY_QUANTITY AS (
    -- Aggregate total quantity per product per year
    SELECT
        DESCRIPTION,
        YEARS,
        SUM(QUANTITY) AS TOTAL_QUANTITY
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY DESCRIPTION, YEARS
),

PRODUCTS_OVER_YEARS AS (
    -- Pivot quantities into separate columns for 2009 and 2010
    SELECT
        DESCRIPTION,
        SUM(CASE WHEN YEARS = 2009 THEN TOTAL_QUANTITY END) AS QUANTITY_2009,
        SUM(CASE WHEN YEARS = 2010 THEN TOTAL_QUANTITY END) AS QUANTITY_2010
    FROM PRODUCT_YEARLY_QUANTITY
    GROUP BY DESCRIPTION
),

QUANTITY_TREND AS (
    -- Calculate change in quantity per product
    SELECT
        DESCRIPTION,
        QUANTITY_2009,
        QUANTITY_2010,
        (QUANTITY_2010 - QUANTITY_2009) AS QUANTITY_CHANGE  -- Positive: increase, Negative: decrease
    FROM PRODUCTS_OVER_YEARS
)

-- Show products present in both years, sorted by highest increase
SELECT *
FROM QUANTITY_TREND
WHERE QUANTITY_2009 IS NOT NULL
  AND QUANTITY_2010 IS NOT NULL
ORDER BY QUANTITY_CHANGE DESC;

