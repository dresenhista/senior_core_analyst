-- Sample estimated GMV model
SELECT
    TRUNC(TO_DATE(loans.checkout_date)) AS date
    , loans.merchant_id
    , merchants.merchant_name
    , SUM(loans.loan_amount) AS gross_merchant_value
FROM main.loans AS loans
LEFT JOIN main.merchants AS merchants
    USING(merchant_id)
GROUP BY 1,2,3
ORDER BY checkout_date ASC