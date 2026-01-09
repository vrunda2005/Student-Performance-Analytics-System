# Student Performance Analytics System

## 📌 Project Overview
The **Student Performance Analytics System** is an end-to-end Data Engineering project that simulates a real-world EdTech analytics platform. It ingests raw student data from various sources, processes it using a robust ETL pipeline, warehouses it in a Star Schema for optimized querying, and performs advanced analytics using Apache Spark.

This project demonstrates proficiency in **Data Modeling, ETL Automation, SQL Transformations, and Big Data Processing**.

---

## 📂 Dataset Description
The project utilizes a synthetic dataset representing a 360-degree view of student activities. The data simulates a school environment with **12,000+ students** and **300,000+ attendance records**.

| Dataset | Description | Key Columns |
| :--- | :--- | :--- |
| **Students** | Demographic details of students. | `Student_ID`, `Name`, `Grade_Level`, `DOB`, `Email` |
| **Attendance** | Daily attendance logs. | `Student_ID`, `Date`, `Status` (Present/Absent) |
| **Performance** | Exam and assessment scores. | `Student_ID`, `Subject`, `Score`, `Term` |
| **Homework** | Homework submission tracking. | `Student_ID`, `Assignment_ID`, `Status`, `Due_Date` |
| **Communication** | Logs of parent-teacher interactions. | `Student_ID`, `Date`, `Type`, `Notes` |

---

## 🚀 Technical Architecture

### 1. Extraction & Loading (EL)
- **Tool**: Python (Pandas)
- **Process**: Raw CSV files are ingested from the `data/` directory.
- **Data Cleaning**: Dates are standardized, and missing values are handled.
- **Staging**: Cleaned data is loaded into **SQLite** staging tables (`stg_students`, `stg_attendance`, etc.).

### 2. Transformation (T)
- **Tool**: SQL (SQLite)
- **Methodology**: **ELT (Extract, Load, Transform)** pattern.
- **Data Modeling**: Staging data is transformed into a **Star Schema**:
    - **Fact Tables**: `Fact_Performance`, `Fact_Attendance` (Transactional data).
    - **Dimension Tables**: `Dim_Student`, `Dim_Date` (Descriptive data).
- **Views**: Aggregated views created for reporting (e.g., `View_Student_Report_Card`).

### 3. Analytics & Reporting
- **Tool**: Apache Spark (PySpark)
- **Process**: Distributed processing to calculate complex metrics.
- **Insights**:
    - Average exam scores by Grade Level.
    - Top-performing students across all subjects.
    - Attendance trends over time.

---

## 💼 Points

**Project: Student Performance Analytics System**
*   **Designed and implemented an end-to-end ETL pipeline** using **Python** and **SQL** to ingest and process over 300k+ records of student data.
*   **Architected a Star Schema Data Warehouse** in SQLite, optimizing data for analytical queries by separating Facts and Dimensions.
*   **Developed distributed data processing jobs** using **Apache Spark (PySpark)** to generate high-performance insights on student grades and attendance.
*   **Automated data quality checks and cleaning** using Pandas to ensure 100% data integrity before loading into the warehouse.
*   **Technologies**: Python, SQL, Apache Spark, Pandas, SQLite, Data Modeling (Star Schema), ETL/ELT.

---

## 🛠️ Project Structure
```
student_360_pipeline/
├── data/               # Raw CSV data files and SQLite Database
├── notebooks/          # Jupyter Notebooks for interactive analysis
├── sql/                # SQL scripts for DDL and transformations
├── src/                # Python source code
│   ├── __init__.py
│   ├── pipeline.py     # Main ETL pipeline script
│   └── spark_analytics.py # PySpark analytics script
├── requirements.txt    # Python dependencies
└── README.md           # Project documentation
```

## ⚙️ How to Run

### Prerequisites
- Python 3.8+
- Java 8+ (for Spark)

### Setup
1.  **Clone & Install Dependencies**:
    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt
    ```

### Execution
1.  **Run ETL Pipeline** (Ingest -> Clean -> Warehouse):
    ```bash
    python src/pipeline.py
    ```
2.  **Run Analytics** (Spark Job):
    ```bash
    python src/spark_analytics.py
    ```
3.  **Explore Data**:
    ```bash
    jupyter notebook notebooks/ETL_Pipeline.ipynb
    ```
