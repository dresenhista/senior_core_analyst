
with cte as (
  select action,count(action) as actionCount
  from funnel
  group by action
  )
  
  
  update funnelNew
  
  set [date] = funnel.action_date,
  num_Loaded = (select actionCount from cte where action = 'Checkout loaded'),
  num_Applied = (select actionCount from cte where action = 'Loan Terms Run'),
  num_approved = (select actionCount from cte where action = 'Loan Terms Approved'),
  num_confirmed = (select actionCount from cte where action = 'Checkout Completed'),
  application_rate = (select cast(actionCount as float) from cte where action = 'Loan Terms Run')/(select cast(actionCount as float) from cte where action = 'Checkout loaded') ,
  approval_rate = (select cast(actionCount as float) from cte where action = 'Loan Terms Approved')/(select cast(actionCount as float) from cte where action = 'Loan Terms Run'),
  confirmation_rate =(select cast(actionCount as float) from cte where action = 'Checkout Completed') /(select cast(actionCount as float) from cte where action = 'Loan Terms Approved')

