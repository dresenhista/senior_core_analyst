import pandas as pd
import datetime

def partition_file():
    file = pd.read_csv("funnel.csv")

    file = file.sort_values(['action_date', 'checkout_id', 'action'])

    file['month'] = pd.to_datetime(file['action_date']).dt.strftime('%m%Y')

    distinct_months = file['month'].drop_duplicates()

    for month_name in distinct_months:
        new_file = file.loc[file['month'] == month_name]
        new_file.to_csv("funnel_" + month_name + ".csv") 
