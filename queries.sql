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
select 
    loans.merchant_id
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
    , listagg(distinct checkout_id, ', ') as checkout_ids
from loans
inner join merchants
    on merchants.merchant_id = loans.merchant_id
group by all
having count(*) > 1 /* finds all loans with the exact same data which I believe to be duplicates */


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
