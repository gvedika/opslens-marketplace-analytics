import pandas as pd
import numpy as np
import os

RAW = "data/raw"
PROCESSED = "data/processed"
os.makedirs(PROCESSED, exist_ok=True)

print("Loading raw data...")

customers = pd.read_csv(f"{RAW}/olist_customers_dataset.csv")
orders = pd.read_csv(f"{RAW}/olist_orders_dataset.csv")
order_items = pd.read_csv(f"{RAW}/olist_order_items_dataset.csv")
payments = pd.read_csv(f"{RAW}/olist_order_payments_dataset.csv")
reviews = pd.read_csv(f"{RAW}/olist_order_reviews_dataset.csv")
products = pd.read_csv(f"{RAW}/olist_products_dataset.csv")
sellers = pd.read_csv(f"{RAW}/olist_sellers_dataset.csv")
geolocation = pd.read_csv(f"{RAW}/olist_geolocation_dataset.csv")
category_translation = pd.read_csv(f"{RAW}/product_category_name_translation.csv")

# ------------------------------------------------------------------
# 1. ORDERS — convert date columns, keep nulls (they're meaningful)
# ------------------------------------------------------------------
print("Cleaning orders...")

date_cols = [
    "order_purchase_timestamp",
    "order_approved_at",
    "order_delivered_carrier_date",
    "order_delivered_customer_date",
    "order_estimated_delivery_date"
]
for col in date_cols:
    orders[col] = pd.to_datetime(orders[col], errors="coerce")

# Flag delivery status issues instead of dropping rows
orders["is_delivered"] = orders["order_delivered_customer_date"].notnull()
orders["is_late"] = (
    orders["order_delivered_customer_date"] > orders["order_estimated_delivery_date"]
)

# ------------------------------------------------------------------
# 2. ORDER ITEMS — convert date, no nulls to handle
# ------------------------------------------------------------------
print("Cleaning order_items...")

order_items["shipping_limit_date"] = pd.to_datetime(order_items["shipping_limit_date"], errors="coerce")

# ------------------------------------------------------------------
# 3. PAYMENTS — already clean
# ------------------------------------------------------------------
print("Payments already clean, no changes needed.")

# ------------------------------------------------------------------
# 4. REVIEWS — convert dates, drop free-text columns (not used for KPIs)
# ------------------------------------------------------------------
print("Cleaning reviews...")

reviews["review_creation_date"] = pd.to_datetime(reviews["review_creation_date"], errors="coerce")
reviews["review_answer_timestamp"] = pd.to_datetime(reviews["review_answer_timestamp"], errors="coerce")

reviews_clean = reviews.drop(columns=["review_comment_title", "review_comment_message"])
reviews_clean = reviews_clean.drop_duplicates(subset="review_id", keep="first")

# ------------------------------------------------------------------
# 5. PRODUCTS — fill missing category with 'unknown', merge English names
# ------------------------------------------------------------------
print("Cleaning products...")

products["product_category_name"] = products["product_category_name"].fillna("unknown")

products = products.merge(
    category_translation,
    on="product_category_name",
    how="left"
)
products["product_category_name_english"] = products["product_category_name_english"].fillna("unknown")

# Fill missing weight/dimension with median (only 2 rows affected)
for col in ["product_weight_g", "product_length_cm", "product_height_cm", "product_width_cm"]:
    products[col] = products[col].fillna(products[col].median())

# Drop the unneeded length/description/photo columns (not used in our KPIs)
products_clean = products.drop(columns=["product_name_lenght", "product_description_lenght", "product_photos_qty"])

# ------------------------------------------------------------------
# 6. SELLERS — already clean
# ------------------------------------------------------------------
print("Sellers already clean, no changes needed.")

# ------------------------------------------------------------------
# 7. CUSTOMERS — already clean
# ------------------------------------------------------------------
print("Customers already clean, no changes needed.")

# ------------------------------------------------------------------
# 8. GEOLOCATION — dedupe to one row per zip prefix (avg lat/lng)
# ------------------------------------------------------------------
print("Deduplicating geolocation...")

geolocation_clean = (
    geolocation.groupby("geolocation_zip_code_prefix")
    .agg({
        "geolocation_lat": "mean",
        "geolocation_lng": "mean",
        "geolocation_city": "first",
        "geolocation_state": "first"
    })
    .reset_index()
)

# ------------------------------------------------------------------
# 9. Save all cleaned files
# ------------------------------------------------------------------
print("Saving cleaned files to data/processed...")

orders.to_csv(f"{PROCESSED}/orders_clean.csv", index=False)
order_items.to_csv(f"{PROCESSED}/order_items_clean.csv", index=False)
payments.to_csv(f"{PROCESSED}/payments_clean.csv", index=False)
reviews_clean.to_csv(f"{PROCESSED}/reviews_clean.csv", index=False)
products_clean.to_csv(f"{PROCESSED}/products_clean.csv", index=False)
sellers.to_csv(f"{PROCESSED}/sellers_clean.csv", index=False)
customers.to_csv(f"{PROCESSED}/customers_clean.csv", index=False)
geolocation_clean.to_csv(f"{PROCESSED}/geolocation_clean.csv", index=False)

print("\n✅ Cleaning complete. Files saved in data/processed/")
print(f"Orders: {orders.shape}")
print(f"Order Items: {order_items.shape}")
print(f"Payments: {payments.shape}")
print(f"Reviews: {reviews_clean.shape}")
print(f"Products: {products_clean.shape}")
print(f"Sellers: {sellers.shape}")
print(f"Customers: {customers.shape}")
print(f"Geolocation (deduped): {geolocation_clean.shape}")