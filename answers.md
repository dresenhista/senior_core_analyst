# Answers to Assignment Questions 1-4
Below are the written answers for questions 1 through 4. Please find the scripts and code within the main folder for
each corresponding programming language (sql / python). The structure is as follows:
- `main` - contains both `python` and `sql` scripts
- `main/python` - contains `question_four.py` script. This script was run locally to partition and output into `data/funnel_partitions`
- `main/sql` - contains sql scripts for questions 1 - 3. These were run locally using SQLite to test, and reformatted with some snowflake specific functions
- `data/funnel_partitions` - output directory for the partitions tables, ran using the python script for question 4

<hr> 

### 1) Please review the integrity of the data. Do you notice any data anomalies? If so, please describe them.
There were a few anomalies that occurred during my EDA of the data tables provided. All the queries in the EDA can be 
found in the file `main/sql/question_one.sql` and each query is commented with an explanation and a summary of the
results. I will also reference each query for each interesting anomaly found below. 

##### Funnel Table Anomalies 
1. The **distribution of the merchants broken down by number of user interactions is quite heavily skewed**. An interaction
here is defined by each row in the funnel table. The range in terms of the number of interactions for each merchant is
quite wide, from the top merchant seeing almost 2 million impressions, while the lowest seeing only 3. While this is not 
a data error, the data distribution here is quite interesting and has some outliers. (Query A1)
2. There are **users that have been assigned user ids, despite never reaching the `Loan Term Run` stage**. Since user ids 
are not assigned until the `Loan Term Run` action, these users should not have user ids. A possible explanation is that 
these users might have reached the `Loan Term Run` action before the date range of the data we received here. However 
it's still worth pointing out that this was a discrepancy in the data. Also, there were users that had more `Loan Term Run` 
actions than `Checkout Loaded`, despite supposedly being further down the funnel. Although, I have checked the flows on
some merchant sites (as of 2024-01-13), and there are instances where you can trigger a module with the learn more cta to 
apply for loan before the checkout screen. Thus, it could be a possible explanation for those edge cases. Until we can
confirm that these are intended behaviours, these should be flagged as potential anomalies (Query A5).


##### Loan Table Anomalies 
1. Similar to user interactions, the merchants have a pretty skewed distribution in terms of loans as well. The number 
of loans range from 1 to 22343 from the lowest to top merchant, and the total loan amounts reflect that too. (Query B1)
2. **MDR and APR are 0 for certain loans.** While these could be promotional offers or special cases, without further context,
it's hard to conclude that these are not just data errors or invalid values. However, there is never a case where MDR 
and APR are both 0, so that could support the fact that it's a promotional thing as there is always a revenue generator.
Nonetheless, it's worth pointing out for further discussion / investigation (Query B6 - B8)
3. **FICO scores have 0 as values.** The range for this score should be 300 - 850, but there are quite a few loans where
it is 0. This could be a nullable field for users that did not return FICO scores, however it's ideal if this variable
had all valid values, as it could prove useful in other analysis and use cases downstream when it comes to predicting user
value. 


##### Merchant Table Anomalies 
1. The merchant id `LWGKASO1U9UXFLAJ` exists in both the `Funnel` and `Loans` table, but not the `Merchants` table. This means
that there is a missing value in our dimension table and should be added in for lookup purposes. (Query C1 - C2)


##### Miscellaneous Anomalies
1. The date fields for both `Funnel` and `Loans` seem to be in string format. They also have timestamp values of 00:00, 
but should ideally be converted to date-time and truncated to just show the date for consistency. (Query D2)
2. The date format is different between `Funnel` and `Loans`, as `Funnel` shows 'mm/dd/yyyy' and `Loans` shows `mm/dd/yy`.
This should be aligned between tables if possible to avoid confusion for stakeholders of these tables. (Query D2)

<br>

### 2) Calculate conversion through the funnel by day
This question's query can be found at `main/sql/question_two.sql`. It's a pivot on the `Funnel` table to get the daily 
totals for each action (step of the funnel) and ultimately the conversion percentage rates. One caveat to highlight is that,
I did not perform any corrections to the anomalies listed in question 1 other than the date column (convert from string 
to date and truncate). The reason for that is because the discussed anomalies (in particular number 2) could be user 
behaviour due to the merchant site's user flow design, as some allowed users to apply before checkout. So while the 
conversion and funnel is somewhat hierarchical, it should be noted that the data does have cases where users did not show 
a user flow that matched the funnel in the same way the conversion rates are flowing.

<br>

### 3) At Affirm we use the concept of GMV (gross merchandises value) which is basically the financed amount of loans generated in a timeframe. Let's say that on a given day, our dashboard that reports GMV aggregated by day and by merchant looks off. Which models would you prioritize investigating and why?
For this question, I created a sample GMV model based on my assumptions for this question. The code can be found at 
`main/sql/question_three.sql`. It essentially aggregates the `Loans` table by day and merchant id, LEFT JOINs `Merchants`
for merchant details and a SUM on the `loan_amount` column. In this case, the primary table to investigate would be the 
`Loans` table. It's the table that is providing the values for GMV, as well as our date and merchant id variables. The 
`Merchants` table here is mostly just a dimensional lookup for the merchant name, and we do not use the `Funnel` table 
to calculate daily merchant GMV. As a result, the `Loans` table would be the highest priority. We should investigate 
this table  for data quality, as well as any upstream models that powers this`Loans` table to root out where this data 
discrepancy may be coming from. There could a chance that a merchant could be missing and making our dashboard look 
strange, so depending on the discrepancy observed we can also look at the `Merchants`table as a secondary point of 
investigation. Overall, the best place to start is definitely the `Loans` model and then working backwards upstream if 
the numbers look off for our dashboard. 

A side note here would also be depending on which BI tool we are using for dashboarding, as there may be a layer that's 
worth investigating at the BI tool level. For instance, if we are using Looker, it may be worth taking a look at the Look 
and autogenerated SQL for that particular dashboard widget to ensure it's not happening at the BI tooling level before 
we do a deep dive into the data models. There could have been changes at the dashboard level, which is difficult to track
and govern for a tool like Looker, so it's worth doing a quick check there before investing a lot of time into a full dive
on the data models.

<br>

### 4) As our data keeps growing the Storage and Replication team is now asking us to partition the data so it increases the performance of queries. Which file (only one) would you see being the most beneficial to optimize for? Which partitions would you choose and why? Please provide a Python script that will load the chosen file and a script that will partition the data.
The best table for partitioning would be the `Funnel` table. It is the largest table with an amalgamation of all the different
steps of the funnel (`action` column). This means that the amount of data that is processed when using this table will 
be quite large and can grow exponentially. Even if certain downstream models only need to evaluate a certain step of the 
funnel, the entire table needs to be queried. Not to mention having repetitive WHERE clauses to filter on actions during
analysis is just an added layer of extra steps. This table currently operates as a log table of all the user steps in the 
funnel, as can be a great intermediate table where we then break them out and partition it into more modular tables. 
So, to further make it more modular and scalable, we can partition this table by the `action` column, where each table 
represents a particular step in the funnel. 

By partitioning on the `action` column and separating each step into its own partitioned table, we will improve efficiency
when users only need to use or analyse certain parts of the funnel. Rather than querying one large table, they can query
smaller and more modular ones to get they need faster. Furthermore, this allows debugging to be a bit easier in certain 
cases, as you can quickly isolate and query individual parts of the funnel to find the source of the issue. The `action`
column is a great choice here, because it logically separates the data via horizontal partitioning into a very intuitive way.
Each step of the funnel is a separate table, and it stores the logs and user interactions pertaining to each step. These 
tables will retain the its data structure and share the same data definitions, and can be combined via UNION very easily. 
This makes it very natural for users to understand and leverage this data, while gaining the added benefits of having more 
modular and quicker queries. There is also a possibility, where if the `Funnel` table is used as an intermediate table, it 
can potentially still be surfaced as a table where analysts can use it for certain use cases. The downstream modular tables 
are still there for more lightweight use cases, but for situations where it's better to have the entire log table (potentially
in cases like the conversion funnel by day model), it is still available to use. 


Additionally, in an ideal world, if the benefits of having the entire pipeline convert the `Funnel` table into only 
partitioned tables without the need of an intermediate table, it might be worth removing that table completely. In other 
words, if most of the need for these models are around more lightweight and efficient querying, it may be better to 
remove the `Funnel` model altogether and replace it with only the partitioned tables. Although you may lose the 
convenience of a single table for certain use cases, the amount of compute and potential tech debt / support it frees up 
each up day, might be worth it over the efficiency loss on handful of use cases of having an intermediate table for 
`Funnel` in production. However, this may be getting out of the scope of this assignment, as we need to create a script
that will load in an existing `Funnel` model and create new partitions, rather than evaluate whether it's more optimal to replace 
the pipeline for this model. In this case, the python script can be found at `main/python/question_four.py`. 

Side note: The script here is created so it can be run and reproduced locally with CSV files and will output CSV files 
as the partitioned tables. In production, this will most likely be connecting to a database to create the tables to the 
db server. There should also be proper tests and orchestration for this task if putting to production. 






