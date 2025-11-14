from src.database_connection import DatabaseConnection

db = DatabaseConnection(
    host='localhost',
    user='root',
    password='YOUR_PASSWORD',
    database='customer_analytics'
)

engine = db.create_connection()
if engine:
    print("✅ MySQL connection successful!")
else:
    print("❌ Connection failed. Check your credentials.")