
-- Q1 Customer Value using Recency, Frequency, Monetary (PostgreSQL-ready)

WITH CUSTOMER_RFM AS (
    SELECT
        CUSTOMERID,
        MAX(INVOICEDATE)::date AS LAST_PURCHASE_DATE,
        COUNT(DISTINCT INVOICENO) AS FREQUENCY,
        SUM(QUANTITY * UNITPRICE) AS MONETARY
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE INVOICENO NOT LIKE 'C%'
      AND CUSTOMERID IS NOT NULL
    GROUP BY CUSTOMERID
),

MAX_DATE AS (
    SELECT MAX(INVOICEDATE)::date AS MAX_DATE
    FROM ONLINE_RETAIL_MASTER_TABLE
)

SELECT
    C.CUSTOMERID,
    -- Recency: days since last purchase
    (M.MAX_DATE - C.LAST_PURCHASE_DATE) AS RECENCY,
    C.FREQUENCY,
    ROUND(C.MONETARY, 2) AS MONETARY
FROM CUSTOMER_RFM C
CROSS JOIN MAX_DATE M
ORDER BY MONETARY DESC;


--Q2 How can customers be ranked based on purchasing recency, frequency, and spending behavior? 

WITH RFM_BASE AS (
    -- Step 1: Compute last purchase date, frequency, monetary per customer
    SELECT
        CUSTOMERID,
        MAX(INVOICEDATE)::date AS LAST_PURCHASE_DATE,
        COUNT(DISTINCT INVOICENO) AS FREQUENCY,
        SUM(QUANTITY * UNITPRICE) AS MONETARY
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE INVOICENO NOT LIKE 'C%'
      AND CUSTOMERID IS NOT NULL
    GROUP BY CUSTOMERID
),

MAX_DATE AS (
    -- Step 2: Get the latest purchase date in the dataset
    SELECT MAX(INVOICEDATE)::date AS MAX_DATE
    FROM ONLINE_RETAIL_MASTER_TABLE
),

RFM_CALCULATED AS (
    -- Step 3: Compute recency in days
    SELECT
        R.CUSTOMERID,
        (M.MAX_DATE - R.LAST_PURCHASE_DATE) AS RECENCY,  -- days since last purchase
        R.FREQUENCY,
        R.MONETARY
    FROM RFM_BASE R
    CROSS JOIN MAX_DATE M
)

-- Step 4: Assign 1-5 scores for R, F, M
SELECT
    CUSTOMERID,
    NTILE(5) OVER (ORDER BY RECENCY ASC) AS R_SCORE,    -- lower days = more recent
    NTILE(5) OVER (ORDER BY FREQUENCY DESC) AS F_SCORE,
    NTILE(5) OVER (ORDER BY MONETARY DESC) AS M_SCORE
FROM RFM_CALCULATED
ORDER BY R_SCORE DESC, F_SCORE DESC, M_SCORE DESC;


--Q3 How can we segment customers into strategic groups such as Champions, Loyal Customers, At Risk, and Lost Customers?
-- RFM Customer Segmentation
WITH RFM_BASE AS (
    -- Step 1: Compute last purchase date, frequency, monetary per customer
    SELECT
        CUSTOMERID,
        MAX(INVOICEDATE)::date AS LAST_PURCHASE_DATE,
        COUNT(DISTINCT INVOICENO) AS FREQUENCY,
        SUM(QUANTITY * UNITPRICE) AS MONETARY
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE INVOICENO NOT LIKE 'C%'
      AND CUSTOMERID IS NOT NULL
    GROUP BY CUSTOMERID
),
MAX_DATE AS (
    -- Step 2: Get the latest purchase date in the dataset
    SELECT MAX(INVOICEDATE)::date AS MAX_DATE
    FROM ONLINE_RETAIL_MASTER_TABLE
),
RFM_CALCULATED AS (
    -- Step 3: Calculate recency in days
    SELECT
        R.CUSTOMERID,
        (M.MAX_DATE - R.LAST_PURCHASE_DATE) AS RECENCY,
        R.FREQUENCY,
        R.MONETARY
    FROM RFM_BASE R
    CROSS JOIN MAX_DATE M
),
RFM_SCORES AS (
    -- Step 4: Assign R, F, M scores (1-5)
    SELECT
        CUSTOMERID,
        NTILE(5) OVER (ORDER BY RECENCY ASC) AS R_SCORE,    -- lower days = more recent
        NTILE(5) OVER (ORDER BY FREQUENCY DESC) AS F_SCORE,
        NTILE(5) OVER (ORDER BY MONETARY DESC) AS M_SCORE,
        RECENCY,
        FREQUENCY,
        MONETARY
    FROM RFM_CALCULATED
)
-- Step 5: Segment customers
SELECT
    CUSTOMERID,
    R_SCORE,
    F_SCORE,
    M_SCORE,
    RECENCY,
    FREQUENCY,
    MONETARY,
    CASE
        WHEN R_SCORE >= 4 AND F_SCORE >= 4 AND M_SCORE >= 4 THEN 'CHAMPIONS'
        WHEN R_SCORE >= 3 AND F_SCORE >= 3 THEN 'LOYAL CUSTOMERS'
        WHEN R_SCORE <= 2 AND F_SCORE >= 3 THEN 'AT RISK'
        WHEN R_SCORE = 1 THEN 'LOST CUSTOMERS'
        ELSE 'POTENTIAL'
    END AS CUSTOMER_SEGMENT
FROM RFM_SCORES
ORDER BY CUSTOMER_SEGMENT, R_SCORE DESC, F_SCORE DESC, M_SCORE DESC;
