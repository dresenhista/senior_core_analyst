--- Question 1
--- Query used to determine if there are data anomalies.

with rates as (select action_date,
count(distinct case when action = 'Checkout Loaded' then  checkout_id end) as Checkout_Loaded_count,
count(distinct case when action = 'Loan Terms Run' then  checkout_id end) as Loan_Term_Runs_Count,
count(distinct case when action = 'Loan Terms Approved' then  checkout_id end) as Loan_Terms_Approved_Count,
count(distinct case when action = 'Checkout Completed' then  checkout_id end) as Checkout_Completed_Count,
count(distinct case when action = 'Loan Terms Run' then  checkout_id end) / count(distinct case when action = 'Checkout Loaded' then checkout_id end) as Application_Rate,
count(distinct case when action = 'Loan Terms Approved' then  checkout_id end) / count(distinct case when action = 'Loan Terms Run' then  checkout_id end) as Approval_Rate,
count(distinct case when action = 'Checkout Completed' then  checkout_id end) / count(distinct case when action = 'Loan Terms Approved' then  checkout_id end) as Confirmation_Rate
from affirm.funnel
group by 1)

select
avg(Checkout_Loaded_count),
avg(Loan_Term_Runs_Count),
avg(Loan_Terms_Approved_Count),
avg(Checkout_Completed_Count),
avg(application_rate),
avg(Approval_rate),
avg(Confirmation_Rate)
from rates


--- Question 2
--- Note: counting on checkout_id, noticed 4907 instances where there was a 0 value for user_id. 

select action_date,
count(distinct case when action = 'Loan Terms Run' then  checkout_id end) / count(distinct case when action = 'Checkout Loaded' then checkout_id end) as Application_Rate,
count(distinct case when action = 'Loan Terms Approved' then  checkout_id end) / count(distinct case when action = 'Loan Terms Run' then  checkout_id end) as Approval_Rate,
count(distinct case when action = 'Checkout Completed' then  checkout_id end) / count(distinct case when action = 'Loan Terms Approved' then  checkout_id end) as Confirmation_Rate
from affirm.funnel
group by 1
