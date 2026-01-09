# Student 360 Pipeline: Deep Dive Explanation

This document provides a detailed, step-by-step explanation of the ETL (Extract, Transform, Load) pipeline code, the concepts behind the database design (Fact vs. Dimension), and how the data flows from raw CSVs to actionable insights.

---

## 1. High-Level Flow: The "ELT" Approach

We follow an **ELT (Extract, Load, Transform)** pattern, which is modern and efficient:

1.  **Extract**: Read raw CSV files (Pandas).
2.  **Load**: Dump them *as-is* (mostly) into "Staging tables" in the database.
3.  **Transform**: Use SQL to clean, join, and structure the data into "Fact" and "Dimension" tables.

---

## 2. Code Walkthrough: Step-by-Step

The main logic is in `src/pipeline.py`. Here is how it works:

### Step 1: `init_db()` - Setting the Foundation
*   **What it does**: Creates the empty tables in the database.
*   **Code**: Executes `sql/1_ddl_schema.sql`.
*   **Key Concept**: It asserts the structure. We drop tables if they exist to ensure we start fresh (good for development).

### Step 2: `load_data_to_staging()` - The "Staging" Layer
This function reads the CSVs and puts them into **Staging Tables**.

*   **What are Staging Tables?** (`stg_students`, `stg_attendance`, etc.)
    *   These are temporary holding areas.
    *   They look exactly like the CSV files.
    *   Data types are usually just `TEXT` because we haven't validated anything yet.

*   **The "Append" vs "Replace" Logic**:
    *   In the code, you see:
        ```python
        df.to_sql(config['table'], conn, if_exists='replace', index=False)
        ```
    *   **Why `replace`?** For Staging, we usually want to wipe out old data and load the freshest batch from the files to avoid duplicates or mixing old/new processing errors.
    *   **If we used `append`**: We would keep adding rows every time the script runs, which would duplicate data in the staging area unless we carefully managed it.

### Step 3: `run_elt_transformations()` - The "Transformation" Layer
This is where the magic happens. We run `sql/2_views_and_procedures.sql`.

*   **Action**: It moves data from **Staging** -> **Data Warehouse (Facts & Dims)**.

#### The Logic: `INSERT INTO ... SELECT`
This is how we "Append" data in SQL.
```sql
INSERT INTO fact_performance (student_key, subject, exam_score, ...)
SELECT 
    d.student_key,
    s.Subject,
    CAST(s.Exam_Score AS INTEGER), -- Transformation: Text to Number
    ...
FROM stg_performance s
JOIN dim_students d ON s.Student_ID = d.student_id;
```
1.  **SELECT**: Grabs raw data from `stg_performance`.
2.  **JOIN**: Looks up the `student_key` from `dim_students` (replacing the raw `Student_ID`).
3.  **CAST**: Converts text "85" to number `85`.
4.  **INSERT**: Puts existing converted rows into the clean `fact_performance` table.

---

## 3. Component Concepts: Fact vs. Dimension vs. Staging

You asked about "how fact start different". Here is the breakdown:

| Table Type | Example | Purpose & Characteristics |
| :--- | :--- | :--- |
| **Staging** | `stg_students` | **Raw Dump**. mirrors CSV. No relationships. All columns are often strings. *Temporary.* |
| **Dimension** | `dim_students` | **The "Nouns"**. Describes *entities* (People, Products, Places).<br>- Contains attributes (Name, DOB).<br>- Uses a **Surrogate Key** (`student_key`) - a simple number (1, 2, 3) to identify rows uniquely, separately from the business ID (`S101`). |
| **Fact** | `fact_attendance` | **The "Verbs" (Events)**. Records things that *happened*.<br>- Contains **Foreign Keys** (`student_key`) linking to Dimensions.<br>- Contains **Measures** (Score, Present/Absent).<br>- These tables grow very fast (millions of rows). |

### Why separate them? (Star Schema)
*   **Efficiency**: We store "John Doe" only once in `dim_students`. In `fact_attendance`, we just use his ID (`1`). This saves space and makes renaming him easy.
*   **Analysis**: It allows us to easily slice data: "Show me average attendance (Fact) by Grade Level (Dimension)".

---

## 4. Pandas & Numpy Under the Hood

To reiterate the Pandas/Numpy connection:
1.  **Storage**: When you load data into `df` in Step 2, Pandas uses **Numpy Arrays** to store columns efficiently in memory (e.g., Dates are stored as `int64` timestamps).
2.  **Vectorization**: When we clean dates:
    ```python
    df[date_col] = pd.to_datetime(df[date_col], errors='coerce').dt.date
    ```
    Pandas loops through the array using C-level optimizations (via Numpy), which is 100x faster than a Python `for` loop.

---

## 5. Summary of the whole flow

1.  **Files** (`students.csv`)
    ⬇️ *(Pandas reads CSV)*
2.  **DataFrame** (Memory, Numpy-backed)
    ⬇️ *(Pandas `to_sql` replace)*
3.  **Staging Table** (`stg_students`)
    ⬇️ *(SQL `INSERT INTO ... SELECT` with JOIN & CAST)*
4.  **Data Warehouse** (`dim_students`, `fact_performance`)
    ⬇️ *(SQL Views)*
5.  **Insights** (`v_student_risk_monitor`)
