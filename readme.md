## Senior Growth Analyst
Hi there!
If you can see this repo, you have moved to the next step of this hiring process, congratulations! This homework assessment should take anywhere from 3 and 8 hours to complete, depending on your technical skills. 

As part of the hiring process at Affirm, we need to evaluate your technical skills.

Some of the hard skills we are trying to evaluate:
* Github (for starters)
* SQL
* Python

This also may be able to evaluate other skills such as your ability to understand and think about data infrastructure, work through engineering problems, as well as formulate hypotheses for investigation.

This take-home assessment has all the components that you will be using at work once you join the team, so hopefully, this is also a good opportunity for you to evaluate the job.

We will also use the data in this repository throughout your interview process. 

## Data 
This Github repo has three files in /data, please use them as reference moving forward.


## Delivery 
Please clone this branch locally and submit your branch using a PR.
Your PR should have the following files:
* a .txt file with the questions and written answers (you can use the .md format for your branch). 
* a .sql file with the queries you used to answer the questions
* a .python file with the script of question 4


## Data Description
`funnel.csv`
Data about events occurring on Affirm's checkout product (try it out at a merchant like Casper to get a sense of the flow)
merchant_id: Unique identifier for the merchant (links to merchants.csv) 
* user_id: Unique identifier for the user (only populated after the user logins when ‘Loan Terms Run’ action takes place)
* checkout_id: Unique identifier for a given checkout (links to loans.csv)
* action: Name of the event, can be "Checkout Loaded" = checkout page was loaded, "Loan Terms Run" = user applied for a loan, "Loan Terms Approved" = user was approved for a loan, "Checkout Completed" = user took the loan for which they were approved
* action_date: Date when the event happened

`loans.csv`
Data on each loan from the ‘Completed Checkout’ action
merchant_id: Unique identifier for the merchant
* user_id: Unique identifier for the user 
* checkout_id: Unique identifier for a given checkout 
* checkout_date: Date when checkout was completed
* loan_amount: total amount of the loan
* user_first_capture: first date the user took out a loan with Affirm (only populated if repeat Affirm user)
* user_dob_year: year the user was born
* loan_length_months: length of the loan in months
* mdr: merchant discount rate (transaction rate charged to the merchant for each loan)
* apr: annual percentage rate (interest rate charged to the user)
* fico_score: score that measures a user’s risk, a higher score means less risk (ranges from 300-850)
* loan_return_percentage: The return Affirm saw on the loan (negative values mean the loan was not paid back in full)
 
`merchants.csv`
Data on each merchant that integrates Affirm's checkout product
* merchant_id: Unique identifier for the merchant
* merchant_name: Name of the merchant
* category: The merchant's industry



## Questions

1. Please review the integrity of the data. Do you notice any data anomalies? If so, please describe them.


|date      |num_loaded|num_applied|num_approved|num_confirmed|application_rate|approval_rate|confirmation_rate|
|----------|----------|-----------|------------|-------------|----------------|-------------|-----------------|
|2016-05-01|100       |80         |60          |30           |0.8             |0.75         |0.50             |
|2016-05-02|120       |90         |81          |63           |0.75            |0.90         |0.78             |


2. Calculate conversion through the funnel by day

3. At Affirm we use the concept of GMV (gross merchandises value) which is basically the financed amount of loans generated in a timeframe. Let's say that on a given day, our dashboard that reports GMV aggregated by day and by merchant looks off. Which models would you prioritize investigating and why?

4. As our data keeps growing the Storage and Replication team is now asking us to partition the data so it increases the performance of queries. Which file (only one) would you see being the most beneficial to optimize for? Which partitions would you choose and why? Please provide a Python script that will load the chosen file and a script that will partition the data.
