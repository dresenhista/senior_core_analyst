-- Question 2

with funnel_per_day as (
	select
		make_date(
            substring(action_date, '/(....) ')::int,
            substring(action_date, '(\d)/')::int,
            substring(action_date, '/(.*)/')::int
        ) as action_date,
		count(distinct
			case
		  		when action = 'Checkout Loaded'
			  		then checkout_id 
			end
		) as num_loaded,
		count(distinct
			case
		  		when action = 'Loan Terms Run'
			  		then checkout_id 
			end
		) as num_applied,
		count(distinct
			case
		  		when action = 'Loan Terms Approved'
			  		then checkout_id 
			end
		) as num_approved,
		count(distinct
			case
		  		when action = 'Checkout Completed'
			  		then checkout_id 
			end
		) as num_confirmed
from affirm.public.funnel
group by 1
), funnel_calcs_per_day as (
	select
		action_date,
		num_loaded,
		num_applied,
		num_approved,
		num_confirmed,
		num_applied/num_loaded::numeric as application_rate,
		num_approved/num_applied::numeric as approval_rate,
		num_confirmed/num_approved::numeric as confirmation_rate
	from funnel_per_day
	order by 1
)
select *
from funnel_calcs_per_day

--Result Snippet:
/*
"action_date","num_loaded","num_applied","num_approved","num_confirmed","application_rate","approval_rate","confirmation_rate"
"2016-01-01",1463,1070,663,397,0.73137388926862611073,0.61962616822429906542,0.59879336349924585219
"2016-01-02",1802,1349,795,485,0.74861265260821309656,0.58932542624166048925,0.61006289308176100629
"2016-01-03",1772,1339,810,488,0.75564334085778781038,0.60492905153099327857,0.60246913580246913580
"2016-01-04",2012,1508,913,554,0.74950298210735586481,0.60543766578249336870,0.60679079956188389923
"2016-01-05",2277,1585,899,577,0.69609134826526130874,0.56719242902208201893,0.64182424916573971079
*/
