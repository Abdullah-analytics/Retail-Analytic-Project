
-- What is the longest consecutive purchase streak (in days) for each customer?

WITH CUSTOMER_PURCHASE_DATES AS (

    -- Get one purchase date per customer (exclude cancellations)
    SELECT 
        CUSTOMERID,
        CAST(INVOICEDATE AS DATE) AS PURCHASE_DATE
    FROM ONLINE_RETAIL_MASTER_TABLE
    WHERE INVOICENO NOT LIKE 'C%' 
      AND CUSTOMERID IS NOT NULL
    GROUP BY CUSTOMERID, CAST(INVOICEDATE AS DATE)

), 

STREAK_IDENTIFIER AS (

    -- Create grouping key for consecutive date sequences
    SELECT
        CUSTOMERID,
        PURCHASE_DATE,
        PURCHASE_DATE 
        - (ROW_NUMBER() OVER (
            PARTITION BY CUSTOMERID 
            ORDER BY PURCHASE_DATE
          ) * INTERVAL '1 day') AS STREAK_GROUP
    FROM CUSTOMER_PURCHASE_DATES

),

STREAK_LENGTHS AS (

    -- Count consecutive days per streak group
    SELECT
        CUSTOMERID,
        COUNT(*) AS STREAK_LENGTH
    FROM STREAK_IDENTIFIER
    GROUP BY CUSTOMERID, STREAK_GROUP

)

-- Get longest streak per customer
SELECT
    CUSTOMERID,
    MAX(STREAK_LENGTH) AS LONGEST_STREAK_DAYS
FROM STREAK_LENGTHS
GROUP BY CUSTOMERID
ORDER BY LONGEST_STREAK_DAYS DESC
LIMIT 10;