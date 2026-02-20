
-- How has revenue or sales volume changed across different countries between 2009–2010 and 2010–2011?

WITH COUNTRY_REVENUE AS (
    -- Calculate total revenue per country per year
    SELECT 
        COUNTRY,
        YEARS,
        SUM(QUANTITY * UNITPRICE) AS TOTAL_REVENUE
    FROM ONLINE_RETAIL_MASTER_TABLE
    GROUP BY COUNTRY, YEARS
)

SELECT 
    A.COUNTRY,

    -- Revenue difference between 2011 and 2009–2010
    (B.REVENUE_2011 - A.REVENUE_2009_2010) AS REVENUE_CHANGE,

    -- Percentage growth
    ROUND(
        (B.REVENUE_2011 - A.REVENUE_2009_2010) 
        * 100.0 / A.REVENUE_2009_2010,
        2
    ) AS REVENUE_PERCENTAGE,

    -- Business-friendly growth label
    CASE
        WHEN (B.REVENUE_2011 - A.REVENUE_2009_2010) > 0 THEN 'INCREASE'
        WHEN (B.REVENUE_2011 - A.REVENUE_2009_2010) < 0 THEN 'DECREASE'
        ELSE 'NO CHANGE'
    END AS SALES_GROWTH

FROM 
    -- Aggregate revenue for 2009–2010
    (
        SELECT 
            COUNTRY,
            SUM(TOTAL_REVENUE) AS REVENUE_2009_2010
        FROM COUNTRY_REVENUE
        WHERE YEARS IN (2009, 2010)
        GROUP BY COUNTRY
    ) A

JOIN 
    -- Aggregate revenue for 2011
    (
        SELECT 
            COUNTRY,
            SUM(TOTAL_REVENUE) AS REVENUE_2011
        FROM COUNTRY_REVENUE
        WHERE YEARS = 2011
        GROUP BY COUNTRY
    ) B

ON A.COUNTRY = B.COUNTRY

ORDER BY REVENUE_CHANGE DESC, REVENUE_PERCENTAGE DESC;
