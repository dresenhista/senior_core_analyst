
Question 1

SELECT date, Round(num_applied / num_loaded,2) AS apprate_check,
	application_rate,
	Round(num_approved / num_applied,2) AS approvate_check,
	approval_rate,
	Round(num_confirmed / num_approved,2) AS confirmrate_check,
	confirmation_rate
FROM integrity_data;

Question 2

-- Count each event by day
WITH ActionCounts AS (
    SELECT
        action_date,
        action,
        COUNT(*) AS action_count
    FROM
        Funnel
    GROUP BY
        action_date, action
)

-- Then calculate the conversion rates as they move from one event to the other
SELECT
    action_date,
    MAX(CASE WHEN action = 'Checkout Loaded' THEN action_count END) AS Checkoutloaded_count,
    MAX(CASE WHEN action = 'Loan Terms Run' THEN action_count END) AS Loansrun_count,
    MAX(CASE WHEN action = 'Loan Terms Approved' THEN action_count END) AS Loansapproved_count,
    MAX(CASE WHEN action = 'Checkout Completed' THEN action_count END) AS Checkoutcompleted_count,
    MAX(CASE WHEN action = 'Loan Terms Run' THEN action_count END)::FLOAT / MAX(CASE WHEN action = 'Checkout Loaded' THEN action_count END) AS Loansrun_conversion_rate,
    MAX(CASE WHEN action = 'Loan Terms Approved' THEN action_count END)::FLOAT / MAX(CASE WHEN action = 'Loan Terms Run' THEN action_count END) AS Loansapproved_conversion_rate,
    MAX(CASE WHEN action = 'Checkout Completed' THEN action_count END)::FLOAT / MAX(CASE WHEN action = 'Loan Terms Approved' THEN action_count END) AS Checkoutcompleted_conversion_rate
FROM
    ActionCounts
GROUP BY
    action_date
ORDER BY
    action_date;

Question 3

--- GMV by Day
SELECT
    l.checkout_date,
    SUM(l.loan_amount) AS gmv_by_day
FROM
    Loans l
JOIN
    Funnel f ON l.checkout_id = f.checkout_id
WHERE
    f.action = 'Checkout Completed'
GROUP BY
    l.checkout_date
ORDER BY
    l.checkout_date;

--- GMV by Merchant 
SELECT
    m.merchant_id,
    m.merchant_name,
    SUM(l.loan_amount) AS gmv_by_merchant
FROM
    Loans l
JOIN
    Funnel f ON l.checkout_id = f.checkout_id
JOIN
    Merchants m ON f.merchant_id = m.merchant_id
WHERE
    f.action = 'Checkout Completed'
GROUP BY
    m.merchant_id, m.merchant_name
ORDER BY
    m.merchant_id;
