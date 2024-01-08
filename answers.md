1. Please review the integrity of the data. Do you notice any data anomalies? If so, please describe them.

I do notice some anomalies. 
First, there are multiple instances of merchant_ids in both the funnel and loans tables that do not exist in the merchants table.
Second, there seems to be 6 duplicate rows of data in the funnel and loans tables. All the data is the same, except for the checkout id. Now in some cases these might be correct, but I'd assume that in most cases users are not taking out 2 loans of the same amount in the same day.

2. Calculate conversion through the funnel by day

please refer to SQL in queries.sql

3. At Affirm we use the concept of GMV (gross merchandises value) which is basically the financed amount of loans generated in a timeframe. Let's say that on a given day, our dashboard that reports GMV aggregated by day and by merchant looks off. Which models would you prioritize investigating and why?

If on a given day the dashboard that reports GMV aggregated by day and by merchant looks off I would prioritize checking the loans and funnel models. As the loans model contains all the financial data that goes into calculating the GMV its the most likely 
culprit for the error. If I examined the loans model and couldn't find any errors, I would move on to ensuring that a users actions are being recorded correctly in the funnel models. 

4. As our data keeps growing the Storage and Replication team is now asking us to partition the data so it increases the performance of queries. Which file (only one) would you see being the most beneficial to optimize for? Which partitions would you choose and why? Please provide a Python script that will load the chosen file and a script that will partition the data.

I would partition the funnel file as it contains the most data by far and I believe that this table will predominantly be queried using a filter on the action_date column. 
The first partition I would choose would be action_date because sorting this data by date would allow for any rows that do not fall into the date range provided in a query to be avoided/skipped as they are contained within a different partition. 
If the first partition on action_date was not enough, I would add another on Merchant_id as I believe this is the second most used in where clauses. 

I'm not as familiar with Python as I am SQL so I wasn't 100% sure how I was expected to partition the data. 
I wrote a script that takes the funnel.csv file, sorts it by action_date, checkout_id and action and exports the data into 3 new csv files that break the data up by the month in which the action took place. 