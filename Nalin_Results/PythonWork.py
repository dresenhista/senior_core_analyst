import csv
import os
import pandas as pd

### load csv file, select columns to partition on and create and output folder for partitioned data
input_file = "loans.csv"
partition_cols = ["merchant_id", "checkout_date"]
output_folder = "partition_folders_2"

### Function to partition data
def partition_csv(input_file, output_folder, partition_columns):
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    partition_writers = {}

    with open(input_file, 'r') as csv_file:
        reader = csv.DictReader(csv_file)

        for row in reader:

            key = tuple(row.get(column, 'default') for column in partition_columns)
            date_rev = str(pd.to_datetime(key[1]))[0:10]
            key = (key[0], date_rev)

            subfolder = os.path.join(output_folder, str(key[0]))
            if not os.path.exists(subfolder):
                os.makedirs(subfolder)

            partition_file = os.path.join(subfolder, f'{key[1]}.csv')

            if key not in partition_writers:
                partition_writers[key] = csv.DictWriter(open(partition_file, 'w', newline=''), fieldnames=reader.fieldnames)
                partition_writers[key].writeheader()

            partition_writers[key].writerow(row)

partition_csv(input_file, output_folder, partition_cols)
