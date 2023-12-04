
import pandas as pd
import psycopg
from sqlalchemy import create_engine


df = pd.read_csv('loans.csv')


db_params = {
    'host': '*****host',
    'dbname': '****gres',
    'user': '****gres',
    'password': '**mi'
}


# In[14]:


engine = create_engine(f"postgresql://{db_params['user']}:{db_params['password']}@{db_params['host']}/{db_params['dbname']}")
df.to_sql('loans', engine, if_exists='replace', index=False)



# In[18]:


import psycopg2
from sqlalchemy import create_engine


db_params = {
    'host': '*****host',
    'dbname': '****gres',
    'user': '****gres',
    'password': 'Rimi'
}


partition_columns = ['checkout_date', 'loan_amount']
table_name = 'loans3'


conn = psycopg2.connect(**db_params)
cursor = conn.cursor()


partition_sql = f"""
    CREATE TABLE {table_name} (
        checkout_date DATE,
        loan_amount NUMERIC
    )
    PARTITION BY RANGE (checkout_date, loan_amount);
"""


cursor.execute(partition_sql)


conn.commit()
cursor.close()
conn.close()

print(f"Table '{table_name}' partitioned by {', '.join(partition_columns)}.")


# In[ ]:




