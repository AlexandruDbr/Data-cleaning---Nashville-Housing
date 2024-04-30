from sqlalchemy import create_engine
import pyodbc
import pandas as pd

#connect to DB
engine = create_engine('mssql+pyodbc://@<server name>/<DB name>?driver=<DB driver>')

#import file

file_path  = r"<your file path>"

df = pd.read_excel(file_path)
df.to_sql("NashvilleHousing", engine, if_exists= 'replace')

