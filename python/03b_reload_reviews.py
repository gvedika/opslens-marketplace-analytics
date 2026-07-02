import pandas as pd
from sqlalchemy import create_engine

server = 'localhost\\SQLEXPRESS'
database = 'OpsLens'
driver = 'ODBC Driver 18 for SQL Server'

connection_string = (
    f"mssql+pyodbc://@{server}/{database}"
    f"?driver={driver.replace(' ', '+')}"
    f"&trusted_connection=yes"
    f"&TrustServerCertificate=yes"
)

engine = create_engine(connection_string, fast_executemany=True)

print("Loading fact_reviews (deduplicated)...")
reviews = pd.read_csv("data/processed/reviews_clean.csv")
reviews.to_sql("fact_reviews", engine, if_exists="append", index=False)

print(f"\n✅ fact_reviews loaded successfully. Rows: {reviews.shape[0]}")