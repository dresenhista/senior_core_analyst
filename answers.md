## Answers
1. Please review the integrity of the data. Do you notice any data anomalies? If so, please describe them.


|date      |num_loaded|num_applied|num_approved|num_confirmed|application_rate|approval_rate|confirmation_rate|
|----------|----------|-----------|------------|-------------|----------------|-------------|-----------------|
|2016-05-01|100       |80         |60          |30           |0.8             |0.75         |0.50             |
|2016-05-02|120       |90         |81          |63           |0.75            |0.90         |0.78             |


    The logic used for calculating rate metrics look consistent:
    application_rate = num_applied/num_loaded
    approval_rate = num_approved/num_applied
    confirmation_rate = num_confirmed/num_approved

    From the given dataset, there is no data for May 2016 that I could compare with the table summary here to detect any anomalies except that application_rate has 1 decimal point whereas the others have 2 decimal places.
    Also, the approval to confirmation conversion on 2nd May,2016 is comparatively higher than 1st May,2016. This can be further looked into to ensure there are no duplicate entries in the funnel data.

    Aside it, I couldn't notice any data anomalies in the summary here.

    Although, I also looked into the main dataset to check for data integrity issues and found a few issues:
        1. From the funnel data, there are 40671 distinct checkout_ids where user action is Checkout Completed, meaning 40671 loans got taken by the users from the period of 1/1/2016 to 3/9/2016. But loans table has 43687 distinct checkout_ids for the same time period, which indicates there are some errorenous loan records which has no proper linkage to checkout action from funnel.
        2. In the Loans data, permitted Fico score range should be between 300-850, but the min value of Fico score is 0
    
    I've attached the queries used for these analyses in queries.sql file.

2. Calculate conversion through the funnel by day

    
    Here's the definition of conversion rate:
    = (Number of users who completed a desired action) / (Total number of users who entered the funnel)

    Total number of users who entered the funnel = Number of users from "Checkout Loaded" action.

    I've attached the SQL query in queries.sql file and conversion_funnel_output.csv has the final output.

3. At Affirm we use the concept of GMV (gross merchandises value) which is basically the financed amount of loans generated in a timeframe. Let's say that on a given day, our dashboard that reports GMV aggregated by day and by merchant looks off. Which models would you prioritize investigating and why?
    
   
    Assumption:
    From my understanding, I assume that there's a transformation model that takes loans & merchant data as inputs and builds a view of GMV at date & merchant level.

    
    Based on the above assumption, the potential causes for discrepancy in GMV could be:
        1. Duplicate records for same user_id/checkout_id/checkout_date
        2. Duplicate values in merchant dimension table
        3. Anomalies in loan amount
        4. Missing loan data for given day/timeframe
    
    Scenario 1 - Primary Key constraint not present in loans & merchant
    If PK constraint is not present in loans table, then I would prioritize analyze for any duplicate loan records for the same user_id/checkout_id/checkout_date combination. In the same manner, if there are any duplicate reocrds for the same merchant_id, it needs to be corrected. 
    By removing duplicates we can address the initial cause of differences in GMV values in a given time period.
    
    Scenario 2 - Primary Key constraints are present
    If PK contraints are already present, then we can safely assume that duplicate records issue wouldn't be present as it would be caught at the time of data ingestion.
    The next order of analysis would be :
        1. look at the loan amounts to catch any anomalous values , such as negative amounts or very high amounts (for ex - 50k+)
        2. If there are any missing loan records for a specific time frame, which will further trickle down to fixing the pipeline that flows data into loans when user sucessfully completes Checkout Completed action.
    
    
4. As our data keeps growing the Storage and Replication team is now asking us to partition the data so it increases the performance of queries. Which file (only one) would you see being the most beneficial to optimize for? Which partitions would you choose and why? Please provide a Python script that will load the chosen file and a script that will partition the data.
 
    
    Loans dataset need to prioritized for partitioning because:
        1. Based on the nature of business and reporting analysis, Loans data is the most valuable and beneficial data for analysts. The query performance of loans data should be optimal for read in such a way that multiple users can efficiently query the data and create metrics/KPIs for analytics.
        2. The best approach to partition the loans table is by day based on checkout_date. Having day level partition allows for drill down analysis of GMV (gross merchandise value) report trends and conduct RFM (receny, frequency, monetary) analysis on Affirm's customers.
        3. Although funnel ,which is more like an event data stream, could also quickly grow in size, its potential usecase is limited to understanding conversion funnel whereas Loans is the central transaction table that houses information about financing and credit information for users/merchants.
        4. Attached python script (question_4.py) to load loans data & save it as partitioned table (can be run in Databricks).