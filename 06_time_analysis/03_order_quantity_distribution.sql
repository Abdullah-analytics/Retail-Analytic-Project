
-- -- Q12: How has the distribution of order quantities changed? (small vs large orders)
WITH TOTAL_ORDERS_DISTRIBUTION AS (
    -- Count small and large order quantities per year
    SELECT
        YEARS,
        COUNT(CASE WHEN QUANTITY <= 15 THEN 1 END) AS SMALL_ORDER,
        COUNT(CASE WHEN QUANTITY > 15 THEN 1 END) AS LARGE_ORDER
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY YEARS
)

-- Final result showing order distribution by year
SELECT
    YEARS,
    SMALL_ORDER,
    LARGE_ORDER
FROM TOTAL_ORDERS_DISTRIBUTION
ORDER BY YEARS;
