/* QUESTION 1 */

/* Funnel checks by checkout id*/
select 
    funnel.checkout_id
  , count(case when funnel.action = 'Checkout Loaded' then funnel.checkout_id end) as num_loaded
  , max(case when funnel.action = 'Checkout Loaded' 
            then to_date(SUBSTR(funnel.action_date, 0, charindex(' ', funnel.action_date))) end) as time_loaded
  , count(case when funnel.action = 'Loan Terms Run' then funnel.checkout_id end) as num_applied
  , max(case when funnel.action = 'Loan Terms Run'
            then to_date(SUBSTR(funnel.action_date, 0, charindex(' ', funnel.action_date))) end) as time_applied
  , count(case when funnel.action = 'Loan Terms Approved' then funnel.checkout_id end) as num_approved
  , max(case when funnel.action = 'Loan Terms Approved'
            then to_date(SUBSTR(funnel.action_date, 0, charindex(' ', funnel.action_date))) end) as time_approved
  , count(case when funnel.action = 'Checkout Completed' then funnel.checkout_id end) as num_confirmed
  , max(case when funnel.action = 'Checkout Completed'
            then to_date(SUBSTR(funnel.action_date, 0, charindex(' ', funnel.action_date))) end) as time_confirmed
from funnel
group by 1
having 
    time_loaded > time_applied
    or time_loaded > time_approved
    or time_loaded > time_confirmed
    or time_applied > time_approved
    or time_applied > time_confirmed
    or time_approved > time_confirmed
    or num_loaded > 1
    or num_applied > 1
    or num_approved > 1
    or num_confirmed > 1

/* Funnel and loans checks */
select 
    funnel.checkout_id
    , count(distinct funnel.merchant_id) as merchant_count
    , count(distinct funnel.user_id) as user_count
    , count(distinct funnel.action_date) as date_count
    , max(case when merchants.merchant_id is null then true else false end) as missing_merchant
    , max(case when funnel.action = 'Checkout Completed' and loans.checkout_id is null then true else false end) as missing_loan_data
    , max(case when funnel.action = 'Checkout Completed' 
        and to_date(SUBSTR(funnel.action_date, 0, charindex(' ', funnel.action_date))) != to_date(SUBSTR(replace(loans.checkout_date, '/16 ', '/2016 '), 0, charindex(' ', replace(loans.checkout_date, '/16 ', '/2016 ')))) then true else false end) as missmatched_checkout_date
from funnel
left join merchants
    on merchants.merchant_id = funnel.merchant_id
left join loans
    on loans.checkout_id = funnel.checkout_id
group by 1
having 
    merchant_count > 1
    or user_count > 1
    or date_count > 1 /* Not necessarily this one since they could be purchasing confirming after midnight, would know for sure if time was available */
    or missing_merchant = true
    or missing_loan_data = true
    or missmatched_checkout_date = true

/* Merchants Checks */
select 
    merchant_id
    , count(*) as duplicates
    , count(distinct merchant_name) as duplicate_ids
    , count(distinct category) as duplicate_category
from merchants
group by 1
having 
    duplicate_ids > 1
    or duplicates > 1
    or duplicate_category > 1 /* I did not check for name duplicates since companies could potentially have the same name */

/* loans checks */
with loan_check as 
(
    select 
        loans.checkout_id
        , loans.merchant_id
        , loans.user_id
        , loans.checkout_date
        , loans.loan_amount
        , loans.down_payment_amount
        , loans.users_first_capture
        , loans.user_dob_year
        , loans.loan_length_months
        , loans.mdr
        , loans.apr
        , loans.fico_score
        , loans.loan_return_percentage
        , max(case when funnel.checkout_id is null then true else false end) as missing_funnel_data
        , listagg(distinct loans.checkout_id, ', ') over (partition by loans.merchant_id
                                                           , loans.user_id
                                                           , loans.checkout_date
                                                           , loans.loan_amount
                                                           , loans.down_payment_amount
                                                           , loans.users_first_capture
                                                           , loans.user_dob_year
                                                           , loans.loan_length_months
                                                           , loans.mdr
                                                           , loans.apr
                                                           , loans.fico_score
                                                           , loans.loan_return_percentage) as checkout_ids
        , case when count(distinct loans.checkout_id) over (partition by loans.merchant_id
                                                           , loans.user_id
                                                           , loans.checkout_date
                                                           , loans.loan_amount
                                                           , loans.down_payment_amount
                                                           , loans.users_first_capture
                                                           , loans.user_dob_year
                                                           , loans.loan_length_months
                                                           , loans.mdr
                                                           , loans.apr
                                                           , loans.fico_score
                                                           , loans.loan_return_percentage) > 1 then true
            else false end as is_duplicate
    from loans
    inner join merchants_test /*Not left join because I have already determined some are missing */
        on merchants_test.merchant_id = loans.merchant_id
    left join funnel
        on funnel.checkout_id = loans.checkout_id
        and funnel.action ilike '%complete%'
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
)
select * 
from loan_check
where is_duplicate
    or missing_funnel_data 

/* Average Rate Checks */
with 
funnel_flow as 
(
    SELECT
    to_date(substr(action_date, 0, charindex(' ', action_date))) as date
    , count(distinct case when action = 'Checkout Loaded' then checkout_id end) as num_loaded
    , count(distinct case when action = 'Loan Terms Run' then checkout_id end) as num_applied
    , count(distinct case when action = 'Loan Terms Approved' then checkout_id end) as num_approved
    , count(distinct case when action = 'Checkout Completed' then checkout_id end) as num_confirmed
    , round(num_applied/num_loaded, 2) as application_rate
    , round(num_approved/num_applied, 2) as approved_rate
    , round(num_confirmed/num_approved, 2) as confirmed_rate
    , avg(application_rate)  over () as avg_application_rate
    , avg(approved_rate) over () as avg_approved_rate
    , avg(confirmed_rate) over () as avg_confirmed_rate
    FROM funnel
    group by all
    order by 1
)
select  
    date
    , abs(application_rate - avg_application_rate) as application_rate_variance
    , abs(approved_rate - avg_approved_rate) as approved_rate_variance
    , abs(confirmed_rate - avg_confirmed_rate) as confirmed_rate_variance
    , listagg(distinct case 
                when abs(application_rate - avg_application_rate) > 0.1 then 'Application Rate Check'
                when abs(approved_rate - avg_approved_rate) > 0 then 'Approved Rate Check'
                when abs(confirmed_rate - avg_confirmed_rate) > 0 then 'Confirmed Rate Check'
                end, ', ') as check_type
from funnel_flow
where 
    abs(application_rate - avg_application_rate) > 0.1
    or abs(approved_rate - avg_approved_rate) > 0.1
    or abs(confirmed_rate - avg_confirmed_rate) > 0.1
group by all


/* QUESTION 2 */

SELECT
  to_date(substr(action_date, 0, charindex(' ', action_date))) as date
  , count(distinct case when action = 'Checkout Loaded' then checkout_id end) as num_loaded
  , count(distinct case when action = 'Loan Terms Run' then checkout_id end) as num_applied
  , count(distinct case when action = 'Loan Terms Approved' then checkout_id end) as num_approved
  , count(distinct case when action = 'Checkout Completed' then checkout_id end) as num_confirmed
  , round(num_applied/num_loaded, 2) as application_rate
  , round(num_approved/num_applied, 2) as approved_rate
  , round(num_confirmed/num_approved, 2) as confirmed_rate
FROM funnel
group by all
order by 1
