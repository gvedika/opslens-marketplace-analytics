import pandas as pd
from sqlalchemy import create_engine
import datetime

# ------------------------------------------------------------------
# Connection setup
# ------------------------------------------------------------------
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

PROCESSED = "data/processed"

# ------------------------------------------------------------------
# 1. Load dimension tables first (fact tables have FK constraints)
# ------------------------------------------------------------------

print("Loading dim_customers...")
customers = pd.read_csv(f"{PROCESSED}/customers_clean.csv")
customers.to_sql("dim_customers", engine, if_exists="append", index=False)

print("Loading dim_sellers...")
sellers = pd.read_csv(f"{PROCESSED}/sellers_clean.csv")
sellers.to_sql("dim_sellers", engine, if_exists="append", index=False)

print("Loading dim_products...")
products = pd.read_csv(f"{PROCESSED}/products_clean.csv")
products.to_sql("dim_products", engine, if_exists="append", index=False)

print("Loading dim_geography...")
geography = pd.read_csv(f"{PROCESSED}/geolocation_clean.csv")
geography.to_sql("dim_geography", engine, if_exists="append", index=False)

# ------------------------------------------------------------------
# 2. Generate and load dim_date
# ------------------------------------------------------------------
print("Generating dim_date...")

start_date = datetime.date(2016, 1, 1)
end_date = datetime.date(2019, 12, 31)

date_range = pd.date_range(start_date, end_date, freq="D")

dim_date = pd.DataFrame({"date_key": date_range})
dim_date["year"] = dim_date["date_key"].dt.year
dim_date["quarter"] = dim_date["date_key"].dt.quarter
dim_date["month"] = dim_date["date_key"].dt.month
dim_date["month_name"] = dim_date["date_key"].dt.strftime("%B")
dim_date["day"] = dim_date["date_key"].dt.day
dim_date["weekday"] = dim_date["date_key"].dt.weekday
dim_date["weekday_name"] = dim_date["date_key"].dt.strftime("%A")
dim_date["is_weekend"] = dim_date["weekday"].isin([5, 6])

print("Loading dim_date...")
dim_date.to_sql("dim_date", engine, if_exists="append", index=False)

# ------------------------------------------------------------------
# 3. Load fact tables (order matters due to FK constraints)
# ------------------------------------------------------------------

print("Loading fact_orders...")
orders = pd.read_csv(f"{PROCESSED}/orders_clean.csv")
orders.to_sql("fact_orders", engine, if_exists="append", index=False)

print("Loading fact_order_items...")
order_items = pd.read_csv(f"{PROCESSED}/order_items_clean.csv")
order_items.to_sql("fact_order_items", engine, if_exists="append", index=False)

print("Loading fact_payments...")
payments = pd.read_csv(f"{PROCESSED}/payments_clean.csv")
payments.to_sql("fact_payments", engine, if_exists="append", index=False)

print("Loading fact_reviews...")
reviews = pd.read_csv(f"{PROCESSED}/reviews_clean.csv")
reviews.to_sql("fact_reviews", engine, if_exists="append", index=False)

print("\n✅ All data loaded successfully into OpsLens database.")