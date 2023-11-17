                            -----------------------
Question 1

Please review the integrity of the data. Do you notice any data anomalies? If so, please describe them.

I did not notice a few data anomalies which include;

Inconsistent Data Formatting: I see that the application rate number (0.8) on date 2016-05-01 is not consistent with how the remaining rates are presented in 2 decimal places.

Higher approval rates: The approval rate on date 2016-05-02 seems to be a little on the high side of 90% which I wouldn't expect for loan approval rates, so that is something i'll call out. This may be a possible data anomaly, and I would need more data points and insights into the business to conculude on if it is truly a data anomaly.

Outside of these two things I didn't find any other data anaomalies and here are some of the checks I did;

Checking consistency in the calculations: From the dataset, I was able to determine some of the calculations used to arrive at the rates and I confirmed that the calculations were correct. Here are the calculations

Application Rate: num_applied/num_loaded
Approval Rate: num_approved/num_applied
Confirmation Rate: num_confirmed/num_approved

Checking for missing values and outliers: No missing values found in the data evaluated

                       -----------------------------
Question 2

Calculate conversion through the funnel by day such that the data structure is:
- Up to date

Here's my [result](/Users/aderimikelala/Downloads/Conversion Funnel.csv)

                        -------------------------------
Question 3

At Affirm we use the concept of GMV (gross merchandises value) which is basically the financed amount of loans generated in a timeframe. Let's say that on a given day, our dashboard that reports GMV aggregated by day and by merchant looks off. 
                        
                            Which models would you prioritize investigating and why?

Firstly, I would base this decision on what specific anomalies exist in the dashboard and based on more insights into the business but in the absence of that.

I would proritize investigating the GMV model aggregated by merchant.

Due to the following reasons;

Ease of detecting the problem/issue at hand: I would evaluate this model because I believe it will be easier and faster to identify what specifc merchant may be looking off. Having prior insights into the GMVs of merchants at certin points also makes this easier to identify the merchant that is off and then you can dig deeper into the specifi date or other factors.

Possibly less data to go through: The merchant GMV model may also be less than the day model as it is much more aggregated. This therefore makes it easier to identify specific merchants with issues and further streamlines the process towards finding the root cause.

                        --------------------------
Question 4

As our data keeps growing the Storage and Replication team is now asking us to partition the data so it increases the performance of queries.

                        Which file (only one) would you see being the most beneficial to optimize for? 

I would optimize the loans table because it contains most of the columns which most of the core analysis will come from and it would be joined with supporting tables like the funnel and merchant table.

Additionally, it contains a lot of the distinct data because it is capturing only the materialized loans and when it comes to partitioning this is one of the major considerations.

Also, as this is growing database, I see the Loans table growing very large with its already existing higher number of Columns.

                                            Which partitions would you choose and why?

I would choose the checkout_date and Loan_amount as the partitions;

Checkout_date because this field would be used for a lot of aggregation and filtering which has a high impact on query effciency. Additionally, it will be easier to manage the date partition when additioanl data is being added to the table.

Loan_amount because this is a column that would also be used in a number of the analysis to derive additional insights such as the GMV etc. as well as aggregations. Additionally these two fields have a higher level of distinct values which creates more granular partitions and improves efficiency of queries.







