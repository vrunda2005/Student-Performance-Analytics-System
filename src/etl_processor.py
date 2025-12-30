import pandas as pd
import sqlite3
import os
from datetime import datetime

# Configuration
DB_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'student_dwh.db')
SQL_SCRIPT_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'sql')

def get_db_connection():
    return sqlite3.connect(DB_PATH)

def init_db():
    """Initializes the database with DDL scripts if not exists."""
    conn = get_db_connection()
    with open(os.path.join(SQL_SCRIPT_DIR, '1_ddl_schema.sql'), 'r') as f:
        conn.executescript(f.read())
    conn.close()
    print("Database initialized.")

def process_file(file_path):
    """
    Main ETL function.
    1. Identifies file type.
    2. Cleans data using Pandas.
    3. Loads to Staging (SQLite).
    4. Triggers ELT transformation.
    """
    filename = os.path.basename(file_path)
    print(f"Processing file: {filename}")
    
    conn = get_db_connection()
    
    try:
        df = pd.read_csv(file_path)
        
        # 1. Ingestion & Cleaning (Pandas)
        if 'students' in filename:
            # Basic cleaning
            df['Date_of_Birth'] = pd.to_datetime(df['Date_of_Birth'], errors='coerce').dt.date
            table_name = 'stg_students'
            
        elif 'attendance' in filename:
            df['Date'] = pd.to_datetime(df['Date'], errors='coerce').dt.date
            table_name = 'stg_attendance'
            
        elif 'performance' in filename:
            # Remove % sign if present in Pandas before loading (or handle in SQL)
            # Let's do it here to show Python data manipulation
            if 'Homework_Completion_%' in df.columns:
                df.rename(columns={'Homework_Completion_%': 'Homework_Completion_Pct'}, inplace=True)
            table_name = 'stg_performance'
            
        elif 'homework' in filename:
            df['Due_Date'] = pd.to_datetime(df['Due_Date'], errors='coerce').dt.date
            table_name = 'stg_homework'
            
        elif 'communication' in filename:
            df['Date'] = pd.to_datetime(df['Date'], errors='coerce').dt.date
            table_name = 'stg_communication'
            
        else:
            print(f"Skipping unknown file type: {filename}")
            return

        # 2. Load to Staging (Append mode)
        df.to_sql(table_name, conn, if_exists='append', index=False)
        print(f"Loaded {len(df)} rows into {table_name}")

        # 3. ELT Transformation (Trigger SQL logic)
        run_elt_transformations(conn)
        
        # 4. Move to Processed Folder
        processed_dir = os.path.join(os.path.dirname(os.path.dirname(file_path)), 'processed')
        os.rename(file_path, os.path.join(processed_dir, filename))
        print(f"Moved {filename} to processed/")

    except Exception as e:
        print(f"Error processing {filename}: {e}")
    finally:
        conn.close()

def run_elt_transformations(conn):
    """Runs the SQL transformation logic to move data from Staging to Core."""
    print("Running ELT Transformations...")
    with open(os.path.join(SQL_SCRIPT_DIR, '2_views_and_procedures.sql'), 'r') as f:
        # SQLite executescript can run multiple statements
        conn.executescript(f.read())
    print("ELT Transformations complete.")

if __name__ == "__main__":
    # For manual testing
    init_db()
    # Example: process_file('../data/landing/students.csv')
