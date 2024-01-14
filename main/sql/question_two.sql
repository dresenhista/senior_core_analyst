WITH daily_action_totals AS (
    SELECT
        TRUNC(TO_DATE(action_date)) AS date
        , CAST(COUNT(CASE WHEN action = 'Checkout Loaded' THEN action END) AS float) AS num_loaded
        , CAST(COUNT(CASE WHEN action = 'Loan Terms Run' THEN action END) AS float) AS num_applied
        , CAST(COUNT(CASE WHEN action = 'Loan Terms Approved' THEN action END) AS float) AS num_approved
        , CAST(COUNT(CASE WHEN action = 'Checkout Completed' THEN action END) AS float) AS num_confirmed
    FROM main.funnel
    GROUP BY action_date
)

SELECT *
    , ROUND(num_applied / num_loaded, 2) AS application_rate
    , ROUND(num_approved / num_applied, 2) AS aproval_rate
    , ROUND(num_confirmed / num_approved, 2) AS application_rate
FROM daily_action_totals
ORDER BY date ASC