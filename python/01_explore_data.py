import pandas as pd
import os

data_path = "data/raw"

files = [
    "olist_customers_dataset.csv",
    "olist_orders_dataset.csv",
    "olist_order_items_dataset.csv",
    "olist_order_payments_dataset.csv",
    "olist_order_reviews_dataset.csv",
    "olist_products_dataset.csv",
    "olist_sellers_dataset.csv",
    "olist_geolocation_dataset.csv",
    "product_category_name_translation.csv"
]

for file in files:
    path = os.path.join(data_path, file)
    df = pd.read_csv(path)
    print(f"\n{'='*60}")
    print(f"FILE: {file}")
    print(f"{'='*60}")
    print(f"Shape: {df.shape}")
    print(f"Columns: {list(df.columns)}")
    print(f"\nNulls per column:\n{df.isnull().sum()[df.isnull().sum() > 0]}")
    print(f"\nDtypes:\n{df.dtypes}")
    