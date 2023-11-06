## Senior Growth Analyst
Hi there!
If you are able to see this repo, you have moved to the next step of this hiring process, congratulations!

As part of the hiring process at Affirm we need to evaluate your technical skills. This take-home assessment has all the components that you will be using at work once you join the team, so hopefully, this is also a good opportunity to evaluate if you like what you willbe working on.

Some of the hard skills we are trying to evaluate:
* Github (for starters)
* SQL

We will also use the data in this repository throughout your interview process. 

## Data 
This Github repo has three files in data, please use them as reference moving forward.

## Delivery 
Please clone this branch locally and submit your branch using a PR.
Your PR should have the following files:
* a .txt file with the questions and written answers (you can use the md format to your branch). 
* a .sql file with the queries you used to answer the questions
* a .python file with the script of question 4



1. Please review the integrity of the data. Do you notice any data anomalies? If so, please describe them.


|date      |num_loaded|num_applied|num_approved|num_confirmed|application_rate|approval_rate|confirmation_rate|
|----------|----------|-----------|------------|-------------|----------------|-------------|-----------------|
|2016-05-01|100       |80         |60          |30           |0.8             |0.75         |0.50             |
|2016-05-02|120       |90         |81          |63           |0.75            |0.90         |0.78             |


2. Calculate conversion through the funnel by day such that the data structure is:

3. At Affirm we use the concept of GMV which is basically the financed amount of loans generated in a timeframe. Let's say that on a given a day a dashboard that reports GMV by day by merchant looks off. Which models would you prioritize investigating and why? 

4. The Storage and Replication team is now asking us to partition the data so it increases the performance of queries, which file (only one) would you see being the most benefitial of this structure? And which partitions would choose and why? Please provide a python script that will load the chosen file and the script that would partition it following your choice


