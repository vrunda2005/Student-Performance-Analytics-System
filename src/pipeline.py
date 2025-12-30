import pandas as pd
import sqlite3
import os
import glob

# Configuration
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA_DIR = os.path.join(os.path.dirname(PROJECT_ROOT), 'data') # Points to ../data
DB_PATH = os.path.join(PROJECT_ROOT, 'student_dwh.db')
SQL_SCRIPT_DIR = os.path.join(PROJECT_ROOT, 'sql')

def get_db_connection():
    return sqlite3.connect(DB_PATH)

def init_db():
    """Initializes the database with DDL scripts if not exists."""
    print("Initializing Database...")
    conn = get_db_connection()
    with open(os.path.join(SQL_SCRIPT_DIR, '1_ddl_schema.sql'), 'r') as f:
        conn.executescript(f.read())
    conn.close()
    print("Database Schema Created.")

def load_data_to_staging():
    """
    ETL Step: Reads CSVs from Data Folder, cleans them, and loads to Staging tables.
    """
    conn = get_db_connection()
    
    # Map filenames (partial match) to table names and date columns
    file_mappings = {
        'students': {'table': 'stg_students', 'date_cols': ['Date_of_Birth']},
        'attendance': {'table': 'stg_attendance', 'date_cols': ['Date']},
        'performance': {'table': 'stg_performance', 'date_cols': []},
        'homework': {'table': 'stg_homework', 'date_cols': ['Due_Date']},
        'communication': {'table': 'stg_communication', 'date_cols': ['Date']}
    }

    print(f"\nScanning for data in: {DATA_DIR}")
    
    for key, config in file_mappings.items():
        # Find file matching the key
        files = glob.glob(os.path.join(DATA_DIR, f"*{key}*.csv"))
        
        if not files:
            print(f"Warning: No file found for {key}")
            continue
            
        file_path = files[0] # Take the first match
        print(f"Loading {os.path.basename(file_path)} -> {config['table']}...")
        
        try:
            df = pd.read_csv(file_path)
            
            # 1. Data Cleaning (Pandas)
            # Handle Date Columns
            for date_col in config['date_cols']:
                if date_col in df.columns:
                    df[date_col] = pd.to_datetime(df[date_col], errors='coerce').dt.date
            
            # Special handling for Performance table
            if key == 'performance' and 'Homework_Completion_%' in df.columns:
                df.rename(columns={'Homework_Completion_%': 'Homework_Completion_Pct'}, inplace=True)
                
            # 2. Load to SQLite (Staging)
            # if_exists='replace' ensures we start fresh each run for this demo
            df.to_sql(config['table'], conn, if_exists='replace', index=False)
            print(f"  -> Loaded {len(df)} rows.")
            
        except Exception as e:
            print(f"  -> Error loading {key}: {e}")
            
    conn.close()

def run_elt_transformations():
    """
    ELT Step: Runs SQL scripts to transform Staging data into Fact/Dimension tables.
    """
    print("\nRunning ELT Transformations (SQL)...")
    conn = get_db_connection()
    
    try:
        with open(os.path.join(SQL_SCRIPT_DIR, '2_views_and_procedures.sql'), 'r') as f:
            conn.executescript(f.read())
        print("  -> Transformations Complete. Data Warehouse is ready.")
    except Exception as e:
        print(f"  -> Error in SQL Transformations: {e}")
    finally:
        conn.close()

def main():
    print("=== Student 360 ETL Pipeline ===")
    init_db()
    load_data_to_staging()
    run_elt_transformations()
    print("\nPipeline Finished Successfully!")

if __name__ == "__main__":
    main()
