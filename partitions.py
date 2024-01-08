import pandas as pd
import datetime

def partition_file():
    file = pd.read_csv("loans.csv")

    file = file.sort_values(['checkout_date', 'merchant_id'])

    file['month'] = pd.to_datetime(file['checkout_date'], format="mixed").dt.strftime('%m%Y')

    distinct_months = file['month'].drop_duplicates()

    for month_name in distinct_months:
        new_file = file.loc[file['month'] == month_name]
        new_file.to_csv("loans_" + month_name + ".csv") 
