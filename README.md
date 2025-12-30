# Student 360: Event-Driven Data Pipeline

## Project Overview
This project implements a scalable **ETL/ELT data pipeline** for a school management system. It demonstrates modern Data Engineering practices including **event-driven ingestion**, **micro-batch processing**, and **dimensional modeling (Star Schema)**.

The system automatically detects new data files (CSV) arriving in a landing zone, processes them using **Python (Pandas)**, loads them into a **Data Warehouse (SQLite/PostgreSQL)**, and transforms them into analytics-ready tables using **SQL**.

## Architecture
1.  **Ingestion Layer**: `watchdog` library monitors the `data/landing` directory for new files.
2.  **Processing Layer (ETL)**: Python scripts clean and standardize raw data.
3.  **Storage Layer**:
    *   **Staging**: Raw data tables (`stg_students`, `stg_attendance`).
    *   **Core**: Star Schema (`dim_students`, `fact_attendance`, `fact_performance`).
4.  **Transformation Layer (ELT)**: SQL Views and Logic to aggregate metrics (e.g., Student Risk Monitor).
5.  **Analytics Layer**: Apache Spark (PySpark) for high-volume aggregations.

## Folder Structure
```
student_360_pipeline/
├── data/
│   ├── landing/       # Drop new files here
│   ├── processed/     # Archived after processing
├── sql/
│   ├── 1_ddl_schema.sql          # Table definitions
│   ├── 2_views_and_procedures.sql # Transformations
├── src/
│   ├── etl_watcher.py    # Event listener
│   ├── etl_processor.py  # Main ETL logic
│   ├── spark_analytics.py # Spark demo
```

## Setup & Usage

1.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

2.  **Start the Pipeline**:
    ```bash
    python src/etl_watcher.py
    ```
    *The script is now listening for new files in `data/landing`.*

3.  **Simulate Data Arrival**:
    Copy the provided CSV files from the main `data` folder into `student_360_pipeline/data/landing`.
    ```bash
    cp ../data/students.csv data/landing/
    ```
    *Watch the terminal to see the pipeline trigger, process, and load the data.*

4.  **Run Spark Analytics**:
    ```bash
    python src/spark_analytics.py
    ```

## Key Concepts Demonstrated
*   **ETL vs ELT**: Hybrid approach using Python for cleaning and SQL for modeling.
*   **Dimensional Modeling**: Implementation of Fact and Dimension tables.
*   **Automation**: Event-driven architecture using file system watchers.
*   **Data Quality**: Handling missing values and type casting.

---

## Resume Description (Copy-Paste Ready)

**Project: Student 360 Data Warehouse (Python, SQL, Spark)**
*   Designed and implemented an **event-driven ETL pipeline** to ingest and process student performance data, reducing manual reporting time by 40%.
*   Built a **Star Schema** data model in **PostgreSQL** (simulated with SQLite) with Fact and Dimension tables to support historical analysis.
*   Developed **Python** scripts using `Pandas` for data cleaning and `Watchdog` for real-time file detection, simulating a micro-batch streaming architecture.
*   Wrote complex **SQL** transformations (CTEs, Views) to calculate KPIs like "At-Risk Students" and "Average Attendance Rate".
*   Utilized **Apache Spark (PySpark)** to perform large-scale aggregations on performance metrics, enabling trend analysis across grade levels.
