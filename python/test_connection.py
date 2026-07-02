import pyodbc
from sqlalchemy import create_engine, text

# Connection details
server = 'localhost\\SQLEXPRESS'
database = 'OpsLens'
driver = 'ODBC Driver 18 for SQL Server'

connection_string = (
    f"mssql+pyodbc://@{server}/{database}"
    f"?driver={driver.replace(' ', '+')}"
    f"&trusted_connection=yes"
    f"&TrustServerCertificate=yes"
)

try:
    engine = create_engine(connection_string)
    with engine.connect() as conn:
        result = conn.execute(text("SELECT @@VERSION"))
        for row in result:
            print("✅ Connected successfully!")
            print(row[0])
except Exception as e:
    print("❌ Connection failed.")
    print(e)
    