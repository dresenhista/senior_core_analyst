import pathlib import Path
import pandas as pd

def create_partitions(import_table, export_prefix, partition_column, outdir, project_root):
    '''
    Performs horizontal partition, and outputs partitioned tables from a single table
    based on specific categorical column. Run script from within script folder for best results.

    Keyword Arguments:
    import_table:      CSV file path of table to import
    export_prefix:     The prefix of the output file where the convention is "export_prefix_partition.csv"
    partition_column:  A categorical column that the table will be partitioned on
    outdir:            The output directory for the partitioned tables; use relative path from project root
    project_root:      The project root. Script will auto-detect this, but can replace with manual path if not working correctly
    '''

    # import table and get our partitions
    df = pd.read_csv(import_table)
    partitions = df[partition_column].unique()

    # output a table for every subset of data involving each of our partitions
    for partition in partitions:
        df_output = df[df[partition_column]==partition]

        # create output directory if not it does not exist
        outdir_path = project_root / outdir
        outdir_path.mkdir(parents=True, exist_ok=True)

        # create the data tables based on the output directory for each partition and embed into filename
        suffix = str.lower(partition).replace(" ", "_")
        output_file_path = outdir_path / f"{export_prefix}_{suffix}.csv"
        df_output.to_csv(output_file_path)

if __name__ == "__main__":
    project_root = Path(__name__).resolve().parent.parent.parent
    import_table = project_root / 'data/funnel.csv'
    export_prefix = 'funnel'
    partition_column = 'action'
    outdir = 'data/funnel_partitions'

    create_partitions(import_table, export_prefix, partition_column, outdir, project_root)
    print(f"Partition tables created successfully. Files created at {project_root / outdir}.")
