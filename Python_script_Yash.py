import pandas as pd
import os

def partition_data(file_path, partition_columns, output_dir):
   
    # Load the dataset
    df = pd.read_csv(file_path)

    # Convert columns to datetime if they're dates
    for col in partition_columns:
        if df[col].dtype == 'object':
            try:
                df[col] = pd.to_datetime(df[col]).dt.date
            except:
                pass

    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Partitioning the data
    grouped = df.groupby(partition_columns)
    for group_keys, group_df in grouped:
        # Create a unique filename for each partition
        file_name = '_'.join(map(str, group_keys)) + '.csv'
        file_path = os.path.join(output_dir, file_name)

        # Save each group to a separate file
        group_df.to_csv(file_path, index=False)
        print(f"Partition created: {file_path}")

if __name__ == "__main__":
   
    file_path = '"C:\Users\ytiwa\Downloads\loans.csv"'

    
    partition_columns = ['checkout_date', 'loan_amount']

   
    output_dir = '"C:\Users\ytiwa\Documents\Affirm"'

   
    partition_data(file_path, partition_columns, output_dir)
