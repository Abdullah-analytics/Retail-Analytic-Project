
-- Countries with improved or declined customer activity

WITH COUNTRY_YEARLY_INVOICES AS (
    
    -- Count distinct non-cancelled invoices per country per year
    SELECT 
        COUNTRY,
        YEARS,
        COUNT(DISTINCT INVOICENO) AS TOTAL_INVOICES
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE INVOICENO NOT LIKE 'C%'   -- Exclude cancelled invoices
    GROUP BY COUNTRY, YEARS
)

SELECT 
    A.COUNTRY,
    A.YEARS AS EARLY_YEAR,
    B.YEARS AS LATER_YEAR,

    A.TOTAL_INVOICES AS EARLY_INVOICES,
    B.TOTAL_INVOICES AS LATER_INVOICES,

    -- Absolute change in invoice count
    (B.TOTAL_INVOICES - A.TOTAL_INVOICES) AS RATE_CHANGE,

    -- Percentage change year-over-year
    ROUND(
        CASE 
            WHEN A.TOTAL_INVOICES = 0 THEN NULL
            ELSE (B.TOTAL_INVOICES - A.TOTAL_INVOICES) 
                 * 100.0 / A.TOTAL_INVOICES
        END,
        2
    ) AS PERCENTAGE_CHANGE,

    -- Business-friendly growth direction
    CASE 
        WHEN (B.TOTAL_INVOICES - A.TOTAL_INVOICES) > 0 THEN 'INCREASE'
        WHEN (B.TOTAL_INVOICES - A.TOTAL_INVOICES) < 0 THEN 'DECREASE'
        ELSE 'NO CHANGE'
    END AS SALES_GROWTH

FROM COUNTRY_YEARLY_INVOICES A
JOIN COUNTRY_YEARLY_INVOICES B
    ON A.COUNTRY = B.COUNTRY
   AND B.YEARS = A.YEARS + 1   -- Compare consecutive years

ORDER BY RATE_CHANGE DESC, PERCENTAGE_CHANGE DESC;
