# Student 360: Data Engineering Pipeline

## Project Overview
This project demonstrates a core **ETL/ELT Data Engineering pipeline** using Python and SQL. It is designed to be simple, educational, and interview-ready.

The goal is to ingest raw CSV data, clean it using **Python (Pandas)**, load it into a **Data Warehouse (SQLite)**, and transform it into a **Star Schema** using **SQL**.

## Architecture
1.  **Extract & Load (ETL)**: Python script (`src/pipeline.py`) reads raw CSVs from the `data/` folder, cleans them (handling dates, renaming columns), and loads them into **Staging Tables** in the database.
2.  **Transform (ELT)**: SQL scripts (`sql/2_views_and_procedures.sql`) take the data from Staging and transform it into **Fact and Dimension tables** (Star Schema).
3.  **Analyze**: SQL Views and Spark scripts provide insights (e.g., At-Risk Students).

## Folder Structure
```
student_360_pipeline/
├── sql/
│   ├── 1_ddl_schema.sql          # Creates Staging, Fact, and Dimension tables
│   ├── 2_views_and_procedures.sql # SQL Logic to populate the Data Warehouse
├── src/
│   ├── pipeline.py       # Main Python script to run the entire flow
│   ├── spark_analytics.py # Advanced analytics using PySpark
├── requirements.txt      # Python dependencies
```

## How to Run

1.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Run the Pipeline**:
    This single command initializes the DB, loads data, and runs transformations.
    ```bash
    python src/pipeline.py
    ```

3.  **Run Spark Analytics** (Optional):
    ```bash
    python src/spark_analytics.py
    ```

## Key Concepts Learned
*   **ETL (Extract, Transform, Load)**: Using Pandas to read files and load them into a database.
*   **ELT (Extract, Load, Transform)**: Using SQL to transform data *inside* the database (modern approach).
*   **Star Schema**: Designing Fact (Events) and Dimension (Entities) tables.
*   **Data Cleaning**: Handling date formats and messy column names in Python.
*   **SQL Skills**: CTEs, Joins, and Aggregations.

## Data Source
The data is located in the `../data` folder relative to this project.
*   `students.csv`
*   `attendance.csv`
*   `performance.csv`
*   `homework.csv`
*   `teacher_parent_communication.csv`
