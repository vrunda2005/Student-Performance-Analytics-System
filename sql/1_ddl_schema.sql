-- ==========================================
-- 1. STAGING AREA (Raw Data Landing)
-- ==========================================

DROP TABLE IF EXISTS stg_students;
CREATE TABLE stg_students (
    Student_ID TEXT,
    Full_Name TEXT,
    Date_of_Birth TEXT,
    Grade_Level TEXT,
    Emergency_Contact TEXT,
    ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS stg_attendance;
CREATE TABLE stg_attendance (
    Student_ID TEXT,
    Date TEXT,
    Subject TEXT,
    Attendance_Status TEXT,
    ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS stg_performance;
CREATE TABLE stg_performance (
    Student_ID TEXT,
    Subject TEXT,
    Exam_Score TEXT,
    Homework_Completion_Pct TEXT,
    Teacher_Comments TEXT,
    ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS stg_homework;
CREATE TABLE stg_homework (
    Student_ID TEXT,
    Subject TEXT,
    Assignment_Name TEXT,
    Due_Date TEXT,
    Status TEXT,
    Grade_Feedback TEXT,
    Guardian_Signature TEXT,
    ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS stg_communication;
CREATE TABLE stg_communication (
    Student_ID TEXT,
    Date TEXT,
    Message_Type TEXT,
    Message_Content TEXT,
    ingestion_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- 2. CORE DATA WAREHOUSE (Star Schema)
-- ==========================================

-- Dimension: Student
DROP TABLE IF EXISTS dim_students;
CREATE TABLE dim_students (
    student_key INTEGER PRIMARY KEY AUTOINCREMENT, -- Surrogate Key
    student_id TEXT UNIQUE,                        -- Natural Key
    full_name TEXT,
    date_of_birth DATE,
    grade_level TEXT,
    current_flag BOOLEAN DEFAULT 1,
    effective_date DATE DEFAULT CURRENT_DATE
);

-- Fact: Daily Attendance
DROP TABLE IF EXISTS fact_attendance;
CREATE TABLE fact_attendance (
    attendance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_key INTEGER,
    date DATE,
    subject TEXT,
    is_present BOOLEAN,
    FOREIGN KEY (student_key) REFERENCES dim_students(student_key)
);

-- Fact: Exam Performance
DROP TABLE IF EXISTS fact_performance;
CREATE TABLE fact_performance (
    performance_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_key INTEGER,
    subject TEXT,
    exam_score INTEGER,
    homework_completion_pct REAL,
    FOREIGN KEY (student_key) REFERENCES dim_students(student_key)
);

-- Fact: Homework
DROP TABLE IF EXISTS fact_homework;
CREATE TABLE fact_homework (
    homework_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_key INTEGER,
    subject TEXT,
    assignment_name TEXT,
    due_date DATE,
    status TEXT,
    grade_feedback TEXT,
    guardian_signature BOOLEAN,
    FOREIGN KEY (student_key) REFERENCES dim_students(student_key)
);

-- Fact: Communication
DROP TABLE IF EXISTS fact_communication;
CREATE TABLE fact_communication (
    communication_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_key INTEGER,
    date DATE,
    message_type TEXT,
    message_content TEXT,
    FOREIGN KEY (student_key) REFERENCES dim_students(student_key)
);
