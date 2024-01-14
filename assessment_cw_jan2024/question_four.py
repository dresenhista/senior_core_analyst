import pandas as pd
import psycopg2
from sqlalchemy import create_engine

db_params = {
    'host': 'localhost',
    'dbname': 'affirm',
    'user': 'admin2',
    'password': '123456'
}

engine = create_engine(f"postgresql://{db_params['user']}:{db_params['password']}@{db_params['host']}/{db_params['dbname']}")
conn = psycopg2.connect(**db_params)
cursor = conn.cursor()

table_name = 'funnel_partitioned'

partition_sql = f"""
    CREATE TABLE {table_name} (
        merchant_id VARCHAR,
        user_id VARCHAR,
        checkout_id VARCHAR,
        action VARCHAR,
        action_date VARCHAR
    )
    PARTITION BY RANGE (action_date);

    CREATE TABLE funnel_y2016m01 PARTITION OF {table_name} 
    FOR VALUES FROM ('2016-01-01') TO ('2016-02-01');

    CREATE TABLE funnel_y2016m02 PARTITION OF {table_name} 
    FOR VALUES FROM ('2016-02-01') TO ('2016-03-01');

    CREATE TABLE funnel_y2016m03 PARTITION OF {table_name} 
    FOR VALUES FROM ('2016-03-01') TO ('2016-04-01');
"""

cursor.execute(partition_sql)

df = pd.read_csv('data/funnel.csv')
df['action_date'] = pd.to_datetime(df['action_date'])

df.to_sql(name=table_name, con=engine, if_exists='append', index=False)

conn.commit()
cursor.close()
conn.close()
