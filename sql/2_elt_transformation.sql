-- ==========================================
-- 2. ELT TRANSFORMATION LOGIC (Staging -> DW)
-- ==========================================

-- 2.1 Upsert Logic for Dimensions (SCD Type 1)
-- We insert new students. Updates are skipped for simplicity in this demo.
INSERT INTO dim_students (student_id, full_name, date_of_birth, grade_level)
SELECT DISTINCT 
    Student_ID, 
    TRIM(Full_Name), -- Clean whitespace
    Date_of_Birth, 
    Grade_Level
FROM stg_students
WHERE Student_ID NOT IN (SELECT student_id FROM dim_students);

-- 2.2 Load Fact Attendance
-- Transformation: 'Present' -> 1, Others -> 0
INSERT INTO fact_attendance (student_key, date, subject, is_present)
SELECT 
    d.student_key,
    s.Date,
    UPPER(TRIM(s.Subject)), -- Standardization
    CASE WHEN s.Attendance_Status = 'Present' THEN 1 ELSE 0 END
FROM stg_attendance s
JOIN dim_students d ON s.Student_ID = d.student_id;

-- 2.3 Load Fact Performance (Enhanced)
-- Transformations:
-- 1. Subject Standardization (UPPER/TRIM)
-- 2. Data Cleaning (Cap scores at 100)
-- 3. Feature Engineering (Letter Grade)
INSERT INTO fact_performance (student_key, subject, exam_score, letter_grade, homework_completion_pct)
SELECT 
    d.student_key,
    UPPER(TRIM(s.Subject)) as subject_clean,
    
    -- Cleaning: Cap Score at 100 (Outlier Handling)
    CASE 
        WHEN CAST(s.Exam_Score AS INTEGER) > 100 THEN 100 
        WHEN CAST(s.Exam_Score AS INTEGER) < 0 THEN 0
        ELSE CAST(s.Exam_Score AS INTEGER) 
    END as exam_score_clean,
    
    -- Feature Engineering: Letter Grade
    CASE 
        WHEN CAST(s.Exam_Score AS INTEGER) >= 90 THEN 'A'
        WHEN CAST(s.Exam_Score AS INTEGER) >= 80 THEN 'B'
        WHEN CAST(s.Exam_Score AS INTEGER) >= 70 THEN 'C'
        WHEN CAST(s.Exam_Score AS INTEGER) >= 60 THEN 'D'
        ELSE 'F'
    END as letter_grade,

    CAST(REPLACE(s.Homework_Completion_Pct, '%', '') AS REAL)
FROM stg_performance s
JOIN dim_students d ON s.Student_ID = d.student_id;

-- 2.4 Load Fact Homework
INSERT INTO fact_homework (student_key, subject, assignment_name, due_date, status, grade_feedback, guardian_signature)
SELECT 
    d.student_key,
    UPPER(TRIM(s.Subject)),
    TRIM(s.Assignment_Name),
    s.Due_Date,
    s.Status,
    s.Grade_Feedback,
    CASE WHEN s.Guardian_Signature = 'Yes' THEN 1 ELSE 0 END
FROM stg_homework s
JOIN dim_students d ON s.Student_ID = d.student_id;

-- 2.5 Load Fact Communication
INSERT INTO fact_communication (student_key, date, message_type, message_content)
SELECT 
    d.student_key,
    s.Date,
    s.Message_Type,
    s.Message_Content
FROM stg_communication s
JOIN dim_students d ON s.Student_ID = d.student_id;
