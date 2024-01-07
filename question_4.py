import spark

loans_df =  spark.read.csv('loans.csv', header =  True) #load loans.csv file as spark dataframe
loans_df.write.partitionBy('checkout_date').saveAsTable('loans') #this command partitions the spark dataframe by checkout_date and creates loan table in default database