#Question 1

%sql
-- summary of funnel data
SELECT
  MIN(action_date),
  MAX(action_date),
  COUNT(DISTINCT checkout_id),
  COUNT(
    CASE
      WHEN action = "Checkout Completed" THEN 1
    END
  ) AS loan_taken
FROM funnel

-- summary of loans data

SELECT
  COUNT(distinct user_id, checkout_id),
  MIN(loan_amount),
  MAX(loan_amount),
  SUM(loan_amount),
  AVG(loan_amount),
  MIN(loan_length_months),
  MIN(fico_score),
  MAX(fico_score),
  MIN(checkout_date),
  MAX(checkout_date),
  MIN(apr),
  MAX(apr),
  MIN(mdr),
  MAX(mdr)
FROM loan

-- checkout_id discrepancy between loan & funnel

SELECT DISTINCT
loan.checkout_id,
loan.checkout_date,
funnel.action,
funnel.action_date
FROM loan
LEFT JOIN funnel ON loan.checkout_id = funnel.checkout_id AND loan.user_id = funnel.user_id AND funnel.action = "Checkout Completed"



# Question 2
-- get user count for each action by action_date
WITH user_count AS (
  SELECT
    action_date,
    COUNT(
      CASE
        WHEN action = 'Checkout Loaded' THEN 1
      END
    ) AS checkout_loaded,
    COUNT(
      CASE
        WHEN action = 'Loan Terms Run' THEN 1
      END
    ) as loan_terms_run,
    COUNT(
      CASE
        WHEN action = 'Loan Terms Approved' THEN 1
      END
    ) AS loan_terms_approved,
    COUNT(
      CASE
        WHEN action = 'Checkout Completed' THEN 1
      END
    ) AS checkout_completed
  FROM
    funnel
  GROUP BY
    1
  ORDER BY
    1
)
-- calculate user conversion through funnel by action_date
SELECT
action_date,
checkout_loaded,
loan_terms_run,
loan_terms_approved,
checkout_completed,
ROUND((loan_terms_run/checkout_loaded)*100,2) as loan_applied_rate,
ROUND((loan_terms_approved/checkout_loaded)*100,2) as loan_approved_rate,
ROUND((checkout_completed/checkout_loaded)*100,2) as checkout_complete_rate
FROM user_count