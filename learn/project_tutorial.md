# Project Tutorial: How to Run & Code Deep Dive

This document is your step-by-step guide to running the **Student Performance Analytics System** and understanding exactly how the code works line-by-line.

---

## 🚀 Part 1: How to Run the Project

Follow these steps to execute the pipeline from your terminal.

### 1. Prerequisites
Ensure you are in the project root directory:
```bash
cd /home/vrunda/Projects/data_engineer/student_360_pipeline
```
*Note: If you haven't set up the virtual environment yet, run `python3 -m venv venv` and `pip install -r requirements.txt`.*

### 2. Activate Virtual Environment
You need to use the project's Python libraries (Pandas, PySpark).
```bash
source venv/bin/activate
```
*(Your terminal prompt should now show `(venv)`)*.

### 3. Run the Pipeline
Execute the main Python script. This triggers the entire ETL flow.
```bash
python src/pipeline.py
```

### 4. Check the Output
You should see output indicating success:
```text
=== Student Performance Analytics System ===
Initializing Database...
Loading students.csv -> stg_students...
...
Running ELT Transformations (SQL)...
  -> Executing 2_elt_transformation.sql...
  -> Executing 3_analytics_views.sql...
Pipeline Finished Successfully!
```

---

## 🔍 Part 2: Code Walkthrough (Step-by-Step)

Here is what is happening under the hood when you run that command.

### Step 1: Initialize Database (`src/pipeline.py`)

**What it does**: Creates an empty SQLite database and defines the "Raw" and "Clean" table structures.

```python
def init_db():
    # Connects to 'data/student_dwh.db'
    conn = get_db_connection()
    # Runs the DDL (Data Definition Language) script
    with open('sql/1_ddl_schema.sql', 'r') as f:
        conn.executescript(f.read())
```
*   **Key Concept**: Idempotency. We drop tables and recreate them so every run starts fresh.

### Step 2: Extract & Load (The "Staging" Layer)

**What it does**: Reads CSV files using Pandas and dumps them into "Staging" tables.

```python
def load_data_to_staging():
    # ... finds CSV files ...
    df = pd.read_csv(file_path) # Extract
    
    # Load to SQL (Staging Table)
    df.to_sql(config['table'], conn, if_exists='replace', index=False)
```
*   **Why Pandas?**: It handles CSV parsing (quotes, commas, headers) much better than writing your own Python parser.
*   **Why "replace"?**: Staging is temporary. We want the latest file data, not duplicates.

### Step 3: Transform (The "ELT" Layer)

**What it does**: This is where we implemented the **Advanced Transformations**. Instead of Python, we use SQL to clean and enrich data.

The script executes `sql/2_elt_transformation.sql`. Let's look at a snippet from that file:

#### A. Data Cleaning & Feature Engineering
```sql
INSERT INTO fact_performance (..., letter_grade)
SELECT 
    d.student_key,
    UPPER(TRIM(s.Subject)), -- Clean: "math " -> "MATH"
    
    -- Feature Engineering: Create a Letter Grade column
    CASE 
        WHEN s.Exam_Score >= 90 THEN 'A'
        WHEN s.Exam_Score >= 80 THEN 'B'
        ELSE 'F'
    END as letter_grade
    
FROM stg_performance s
JOIN dim_students d ON s.Student_ID = d.student_id;
```
*   **Explanation**:
    1.  **Extracts** from `stg_performance` (Raw Data).
    2.  **Joins** with `dim_students` to get the surrogate `student_key`.
    3.  **Calculates** `letter_grade` on the fly.
    4.  **Inserts** the clean, enriched result into `fact_performance`.

### Step 4: Analytics Views (The "Serving" Layer)

**What it does**: Creates virtual tables (Views) for dashboards.

The script executes `sql/3_analytics_views.sql`.

```sql
CREATE VIEW agg_student_monthly AS
SELECT 
    s.full_name,
    strftime('%Y-%m', a.date) as month,
    COUNT(*) as total_classes,
    SUM(is_present) as days_present
FROM fact_attendance a
JOIN dim_students s ...
GROUP BY s.full_name, month;
```
*   **Why Views?**: We don't pre-calculate this into a table. The database calculates it *when you query it*. This ensures the report is always 100% real-time up to the last ETL run.

---

## 🧠 Summary for Learning

1.  **Pipeline Entry**: `src/pipeline.py` orchestrates everything.
2.  **Raw Data**: CSVs are loaded into **Staging Tables** (`stg_*`) using Pandas.
3.  **Transformation**: SQL scripts (`INSERT INTO ... SELECT`) read Staging tables, clean the data, and fill **Fact/Dimension Tables**.
4.  **Consumption**: **Views** (`v_*`, `agg_*`) provide simplified data for analysis.
