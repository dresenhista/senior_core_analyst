-- SQL queries for data integrity checks across the funnel, loans, and merchants tables

-- Funnel Table Checks
SELECT 
    COUNT(*) AS total_rows, 
    COUNT(DISTINCT merchant_id) AS unique_merchants,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT checkout_id) AS unique_checkouts
FROM funnel;

-- Loans Table Checks
SELECT 
    MIN(user_dob_year) AS min_dob_year,
    MAX(user_dob_year) AS max_dob_year,
    COUNT(*) AS total_loans,
    COUNT(DISTINCT merchant_id) AS unique_merchants
FROM loans
WHERE fico_score = 0 OR user_dob_year < 1900;

-- Merchants Table Checks
SELECT 
    merchant_id,
    COUNT(*) AS count
FROM merchants
GROUP BY merchant_id
HAVING COUNT(*) > 1;


-- SQL query for calculating daily conversion rates in the sales funnel

WITH daily_actions AS (
    SELECT
        action_date,
        action,
        COUNT(*) AS action_count
    FROM
        funnel
    GROUP BY
        action_date, action
),
conversion_rates AS (
    SELECT
        action_date,
        MAX(CASE WHEN action = 'Checkout Loaded' THEN action_count ELSE 0 END) AS num_loaded,
        MAX(CASE WHEN action = 'Loan Terms Run' THEN action_count ELSE 0 END) AS num_applied,
        MAX(CASE WHEN action = 'Loan Terms Approved' THEN action_count ELSE 0 END) AS num_approved,
        MAX(CASE WHEN action = 'Checkout Completed' THEN action_count ELSE 0 END) AS num_confirmed
    FROM
        daily_actions
    GROUP BY
        action_date
)
SELECT
    action_date,
    num_loaded,
    num_applied,
    num_approved,
    num_confirmed,
    COALESCE(num_applied::FLOAT / NULLIF(num_loaded, 0), 0) AS application_rate,
    COALESCE(num_approved::FLOAT / NULLIF(num_applied, 0), 0) AS approval_rate,
    COALESCE(num_confirmed::FLOAT / NULLIF(num_approved, 0), 0) AS confirmation_rate
FROM
    conversion_rates
ORDER BY
    action_date;
