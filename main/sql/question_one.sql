---- FUNNEL TABLE - EDA / Data Quality queries ----

-- A1) Check distribution for merchant interactions by users
-- Query Result: Very skewed distribution, some merchants have a lot of users, while other have very little
SELECT merchant_id
    , COUNT(*) AS user_interactions
FROM main.funnel
GROUP BY merchant_id
ORDER BY user_interactions DESC;


-- A2) Check distribution for user interactions by users
-- Query Result: Only outlier is users with no user ids since they are the larger proportion of users
SELECT user_id
    , COUNT(*) AS interactions
FROM main.funnel
GROUP BY user_id
ORDER BY interactions DESC;


-- A3) Check distribution for user interactions by action
-- Query Result: Nothing too strange, funnel numbers makes sense based on stage
SELECT action
    , COUNT(*) AS user_interactions
FROM main.funnel
GROUP BY action
ORDER BY user_interactions DESC;


-- A4) Check if missing user_id occurs after assignment step (loan terms run)
-- Query Result: Passed, only check out loaded action has missing user ids as expected
SELECT DISTINCT action
FROM main.funnel
WHERE user_id = '0';


-- A5) Check if user_id back filled correctly for all users that went beyond Checkout Loaded Step and vice versa
-- Query Result: Failed, multiple user ids assigned despite never reaching loan terms run stage that were not 0
WITH user_id_check AS (
    SELECT user_id
        , COUNT(CASE WHEN action='Checkout Loaded' THEN action END) AS checkout_loaded_reached
        , COUNT(CASE WHEN action='Loan Terms Run' THEN action END) AS loan_terms_run_reached
    FROM main.funnel
    GROUP BY user_id
)

SELECT *
FROM user_id_check
WHERE checkout_loaded_reached != loan_terms_run_reached = 0;


-- A6) Check for NULL values
-- Query Result: No NULL values
SELECT COUNT(*)
FROM main.funnel
WHERE merchant_id IS NULL
    OR user_id IS NULL
    OR checkout_id IS NULL
    OR action IS NULL
    OR action_date IS NULL;




---- LOANS TABLE - EDA / Data Quality queries ----

-- B1) Check distribution for merchants
-- Query Result: Similar to interactions, it's a pretty widely skewed distribution of loans and total loan amounts
SELECT merchant_id
    , COUNT(*) AS loans
    , SUM(loan_amount) AS loan_amount
    , AVG(loan_length_months) AS avg_loan_duration_months
    , AVG(loan_return_percentage) AS avg_loan_return_percentage
FROM main.loans
GROUP BY merchant_id
ORDER BY loans DESC;


-- B2) Check distribution for users
-- Query Result: Nothing that stood out as a real outlier
SELECT user_id
    , COUNT(*) AS loans
    , SUM(loan_amount) AS loan_amount
    , AVG(loan_length_months) AS avg_loan_duration_months
    , AVG(loan_return_percentage) AS avg_loan_return_percentage
FROM main.loans
GROUP BY user_id
ORDER BY loans DESC;


-- B3) Check NULL or invalid values like 0 for non numeric columns
-- Query Result: No NULLs
SELECT COUNT(*)
FROM main.loans
WHERE merchant_id IS NULL
    OR user_id IS NULL
    OR checkout_id IS NULL
    OR checkout_date IS NULL;


-- B4) Check NULL or invalid values like 0 for loan_amount (numeric)
-- Query Result: No NULLs or invalid
SELECT COUNT(*)
FROM main.loans
WHERE loan_amount IS NULL
    OR loan_amount = 0;


-- B5) Check NULL or invalid values like 0 for user_dob_year (numeric)
-- Query Result: No NULLs or invalid
SELECT COUNT(*)
FROM main.loans
WHERE user_dob_year IS NULL
    OR user_dob_year = 0;


-- B6) Check NULL or invalid values like 0 for mdr (numeric)
-- Query Result: MDR is 0 for certain loans. Might be a promotion or offer
SELECT *
FROM main.loans
WHERE mdr IS NULL
    OR mdr = 0;


-- B7) Check NULL or invalid values like 0 for apr (numeric)
-- Query Result: APR is 0 for certain loans. Might be a promotion or offer
SELECT *
FROM main.loans
WHERE apr IS NULL
    OR apr = 0;


-- B8) Check if MDR and APR are zero in certain cases which may be an error rather than promotional offer
-- Query Result: No cases where both mdr and apr are 0
SELECT *
FROM main.loans
WHERE mdr =0
    AND apr = 0;


-- B9) Check invalid values for FICO Score (range 300-850)
-- Query Result: FICO scores are 0 in some cases, missing values
SELECT DISTINCT fico_score
FROM main.loans
WHERE fico_score < 350
    OR fico_score > 850
    OR fico_score IS NULL;



---- MERCHANTS TABLE - EDA / Data Quality queries ----

-- C1) Check if any missing merchants in merchants table when cross referenced to other tables
-- Query Result: Seems like the Merchant ID LWGKASO1U9UXFLAJ is missing from the merchants table
WITH merchant_funnel AS (
    SELECT merchant_id
        , COUNT(*) AS user_interactions
    FROM main.funnel
    GROUP BY 1
)

SELECT *
FROM merchant_funnel
LEFT JOIN main.merchants
    USING(merchant_id)
ORDER BY user_interactions DESC;


-- C2) Check the same for loans table just in case
-- Query Result: Missing for LWGKASO1U9UXFLAJ merchant id as well
WITH merchant_loans AS (
    SELECT merchant_id
        , COUNT(*) AS loans
    FROM main.loans
    GROUP BY 1
)

SELECT *
FROM merchant_loans
LEFT JOIN main.merchants
    USING(merchant_id)
ORDER BY loans DESC;



---- Miscellaneous EDA / Combined Tables EDA ----

-- D1) Check if all merchants in loans match merchants where checkout was completed in the funnel
-- Query Result: Pass, all checkout completed merchants had loans when cross referencing both tables
WITH merchants_loan_approved AS (
    SELECT DISTINCT merchant_id
    FROM main.funnel
    WHERE action = 'Checkout Completed'
)

, merchants_with_loans AS (
    SELECT DISTINCT merchant_id
    FROM main.loans
)

SELECT approved.merchant_id AS approved
    , loaned.merchant_id AS loaned
FROM merchants_loan_approved AS approved
LEFT JOIN merchants_with_loans AS loaned
    USING(merchant_id)
WHERE loaned.merchant_id IS NULL;


-- D2) Date ranges for each table
-- Query Result: The dates match up, but the date formats are different (funnel has full year, loan has 2 digits only)
SELECT "funnel" AS table_source
    , MIN(action_date) AS min_date
    , MAX(action_date) AS max_date
FROM main.funnel

UNION ALL

SELECT "loan" AS table_source
    , MIN(checkout_date) AS min_date
    , MAX(checkout_date) AS max_date
FROM main.loans;
