
import pandas as pd

# Load loans.csv file
loans_df = pd.read_csv('loans.csv')

# Display the structure of the dataframe
print(loans_df.info())

# Convert 'checkout_date' column to datetime format
loans_df['checkout_date'] = pd.to_datetime(loans_df['checkout_date'])

# Partition the data based on 'merchant_id' and 'checkout_date'
loans_df['year'] = loans_df['checkout_date'].dt.year
loans_df['month'] = loans_df['checkout_date'].dt.month

# Save the partitioned data to parquet format
loans_df.to_parquet('loans_partitioned', partition_cols=['merchant_id', 'year', 'month'], index=False)
