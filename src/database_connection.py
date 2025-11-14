"""
Database Connection Module
Handles MySQL connection and data loading
"""

import pandas as pd
from sqlalchemy import create_engine
import pymysql
from urllib.parse import quote_plus
import warnings
warnings.filterwarnings('ignore')


class DatabaseConnection:
    def __init__(self, host='localhost', user='root', password='your_password',
                 database='customer_analytics', port=3306):
        """
        Initialize database connection
        """
        self.host = host
        self.user = user
        self.password = password
        self.database = database
        self.port = port
        self.engine = None

    def create_connection(self):
        """Create SQLAlchemy engine for MySQL"""
        try:
            # ✅ Properly encode the password so special characters like @, #, %, ! work
            encoded_password = quote_plus(self.password)
            connection_string = (
                f"mysql+pymysql://{self.user}:{encoded_password}@{self.host}:{self.port}/{self.database}"
            )
            print(f"\n🔗 Connection string preview: mysql+pymysql://{self.user}:<hidden>@{self.host}:{self.port}/{self.database}")
            self.engine = create_engine(connection_string)
            print(f"✅ Connected to MySQL database: {self.database}")
            return self.engine
        except Exception as e:
            print(f"❌ Error connecting to database: {e}")
            return None

    def load_dataframe_to_db(self, df, table_name, if_exists='replace'):
        """Load pandas DataFrame to MySQL table"""
        if self.engine is None:
            self.create_connection()

        try:
            df.to_sql(table_name, self.engine, if_exists=if_exists, index=False)
            print(f"✅ Data loaded to table '{table_name}' successfully!")
            print(f"   Rows loaded: {len(df):,}")
        except Exception as e:
            print(f"❌ Error loading data: {e}")

    def execute_query(self, query):
        """Execute SQL query and return results as DataFrame"""
        if self.engine is None:
            self.create_connection()

        try:
            df = pd.read_sql(query, self.engine)
            return df
        except Exception as e:
            print(f"❌ Error executing query: {e}")
            return pd.DataFrame()  # safer than returning None

    def close_connection(self):
        """Close database connection"""
        if self.engine:
            self.engine.dispose()
            print("✅ Database connection closed")


# Example usage for testing connection
if __name__ == "__main__":
    db = DatabaseConnection(
        host='localhost',
        user='root',
        password='icandoit5@A',  # your actual password
        database='customer_analytics'
    )

    engine = db.create_connection()

    if engine:
        print("\n🔍 Test query:")
        try:
            df = pd.read_sql("SELECT NOW() as current_time;", engine)
            print(df)
        except Exception as e:
            print(f"❌ Test query failed: {e}")
        finally:
            db.close_connection()
