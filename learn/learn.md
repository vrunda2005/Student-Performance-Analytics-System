# Learning Guide: Student Performance Analytics System

This guide explains the core Data Engineering concepts used in this project and provides a broader overview of topics you should know for interviews.


---

> **🚀 Start Here**: Want to run the project and see the code in action? Check out the [Project Tutorial & Code Walkthrough](project_tutorial.md).

---

## 📘 Part 1: Concepts Used in This Project

### 1. ETL vs. ELT
*   **What it is**:
    *   **ETL (Extract, Transform, Load)**: Data is extracted, transformed in memory (e.g., using Python/Pandas), and then loaded into the destination.
    *   **ELT (Extract, Load, Transform)**: Data is extracted and loaded immediately into the destination (Staging), and then transformed using the database engine (SQL).
*   **In This Project**:
    *   We use a **Hybrid Approach**.
    *   **ETL**: Python reads CSVs, cleans dates (Transformation), and loads to SQLite.
    *   **ELT**: Once data is in SQLite (Staging tables), we use SQL scripts to join and aggregate it into the final Data Warehouse tables.
*   **Why?**: Python is great for row-by-row cleaning (parsing dates), while SQL is highly optimized for joining and aggregating large datasets already in the database.

### 2. Star Schema Data Modeling
*   **What it is**: A standard design for Data Warehouses consisting of a central **Fact Table** surrounded by **Dimension Tables**.
*   **In This Project**:
    *   **Fact Tables** (Events/Transactions): `Fact_Performance`, `Fact_Attendance`. These contain metrics (scores, status) and foreign keys.
    *   **Dimension Tables** (Context): `Dim_Student`. This contains descriptive attributes (Name, Grade, Email) that don't change often.
*   **Benefit**: Makes queries faster and simpler. You can easily "slice and dice" the Fact data by any Dimension (e.g., "Average Score *by Grade Level*").

### 3. Data Staging
*   **What it is**: A temporary storage area where raw data is landed before transformation.
*   **In This Project**: Tables like `stg_students` and `stg_attendance`.
*   **Benefit**: Allows you to re-run transformations without re-reading the raw files. It acts as a buffer between the source and the final warehouse.

### 4. Distributed Processing (Apache Spark)
*   **What it is**: A framework for processing massive datasets across a cluster of computers.
*   **In This Project**: We use **PySpark** (Python API for Spark) to calculate analytics.
*   **Key Concept**: **DataFrames**. Distributed collections of data organized into named columns. Operations on DataFrames are lazy (they don't run until you call an action like `.show()` or `.write()`).

---

## 📙 Part 2: General Data Engineering Interview Concepts

### 1. Data Warehouse vs. Data Lake
| Feature | Data Warehouse | Data Lake |
| :--- | :--- | :--- |
| **Data Structure** | Structured (Schema-on-Write) | Structured, Semi-structured, Unstructured (Schema-on-Read) |
| **Storage** | Relational Databases (Snowflake, Redshift) | Object Storage (S3, HDFS, Azure Blob) |
| **Purpose** | BI, Reporting, Analytics | Machine Learning, Data Exploration, Archival |
| **Users** | Business Analysts | Data Scientists, Data Engineers |

### 2. Batch vs. Streaming Processing
*   **Batch**: Processing a large volume of data all at once at scheduled intervals (e.g., Daily ETL). *This project is a Batch pipeline.*
*   **Streaming**: Processing data in real-time as it arrives (e.g., Kafka, Spark Streaming). Used for fraud detection, live dashboards.

### 3. ACID Properties (Transactions)
Relational databases (like the SQLite used here) follow ACID rules to ensure data integrity:
*   **A - Atomicity**: All parts of a transaction succeed, or none do.
*   **C - Consistency**: Data goes from one valid state to another.
*   **I - Isolation**: Concurrent transactions don't interfere with each other.
*   **D - Durability**: Once committed, data is saved permanently even if power fails.

### 4. Slowly Changing Dimensions (SCD)
How do you handle data that changes over time (e.g., a student moves to a new grade)?
*   **Type 1 (Overwrite)**: Update the record. History is lost. (Simple, but no audit trail).
*   **Type 2 (Add Row)**: Add a new row with `Effective_Date` and `End_Date`. Keeps full history. (Most common in Data Warehouses).
*   **Type 3 (Add Column)**: Add a `Previous_Grade` column. Keeps limited history.

### 5. Partitioning & Bucketing
Techniques to optimize query performance in Big Data (Spark/Hive):
*   **Partitioning**: Dividing data into folders based on a column (e.g., `data/year=2023/month=01/`). Great for filtering.
*   **Bucketing**: Distributing data into fixed-size files based on the hash of a column (e.g., `Student_ID`). Great for joins.

### 6. Idempotency
*   **Definition**: Running the same pipeline multiple times produces the same result.
*   **Why it matters**: If your pipeline fails halfway, you should be able to restart it without creating duplicate data.
*   **In This Project**: We use `if_exists='replace'` when loading staging tables to ensure idempotency.

---

## 📝 Resume Bullet Points for This Project
*   **"Designed a Hybrid ETL/ELT Pipeline"**: Explain how you combined Python for flexibility and SQL for performance.
*   **"Implemented Star Schema Modeling"**: Discuss how you separated Fact and Dimension tables to optimize analytical queries.
*   **"Leveraged Apache Spark for Analytics"**: Highlight your ability to use distributed computing frameworks for aggregations.
*   **"Ensured Data Quality"**: Mention the cleaning steps (date parsing, handling nulls) performed before loading data.
