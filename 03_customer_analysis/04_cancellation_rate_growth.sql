-- Week 2 - Customer analysis including churn, spending growth, and RFM segmentation completed

--Identify customers with the highest increase in cancellation / return rate across years

WITH TOTAL_ORDERS AS (
    -- Count total non-cancelled orders per customer per year
    SELECT
        CUSTOMERID,
        YEARS,
        COUNT(DISTINCT INVOICENO) AS TOTAL_ORDER
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE INVOICENO NOT LIKE 'C%'
    GROUP BY CUSTOMERID, YEARS
),

CANCEL_ORDERS AS (
    -- Count cancelled / returned orders per customer per year
    SELECT
        CUSTOMERID,
        YEARS,
        COUNT(DISTINCT INVOICENO) AS CANCELED_ORDER
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE INVOICENO LIKE 'C%'
    GROUP BY CUSTOMERID, YEARS
),

CANCELATION_RATE AS (
    -- Calculate cancellation percentage per customer per year
    SELECT
        T.CUSTOMERID,
        T.YEARS,
        T.TOTAL_ORDER,
        COALESCE(C.CANCELED_ORDER, 0) AS CANCELATION,
        ROUND(
            COALESCE(C.CANCELED_ORDER, 0)::NUMERIC / T.TOTAL_ORDER * 100,
            2
        ) AS CANCELATION_PERCENTAGE
    FROM TOTAL_ORDERS T
    LEFT JOIN CANCEL_ORDERS C
        ON T.CUSTOMERID = C.CUSTOMERID
       AND T.YEARS = C.YEARS
    WHERE T.TOTAL_ORDER > 1
),

CANCELATION_COMPARISON AS (
    -- Compare cancellation rate between consecutive years (YoY)
    SELECT
        E.CUSTOMERID,
        E.CANCELATION_PERCENTAGE AS EARLIER_YEAR_CANCELATION,
        L.CANCELATION_PERCENTAGE AS LATER_YEAR_CANCELATION,
        ROUND(
            L.CANCELATION_PERCENTAGE - E.CANCELATION_PERCENTAGE,
            2
        ) AS RATE_INCREASE
    FROM CANCELATION_RATE E
    JOIN CANCELATION_RATE L
        ON E.CUSTOMERID = L.CUSTOMERID
       AND L.YEARS = E.YEARS + 1
)

-- Final result: customers with highest increase in cancellation rate
SELECT *
FROM CANCELATION_COMPARISON
WHERE EARLIER_YEAR_CANCELATION IS NOT NULL
  AND LATER_YEAR_CANCELATION IS NOT NULL
ORDER BY RATE_INCREASE DESC;
