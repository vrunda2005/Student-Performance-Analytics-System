-- ==========================================
-- 3. ADVANCED SQL: VIEWS & ANALYTICS
-- ==========================================

-- VIEW: Student Risk Monitor
-- Identifies students with low attendance (< 80%) OR low exam scores (< 60)
DROP VIEW IF EXISTS v_student_risk_monitor;
CREATE VIEW v_student_risk_monitor AS
WITH AttendanceStats AS (
    -- CTE to calculate attendance percentage per student
    SELECT 
        student_key,
        COUNT(*) as total_classes,
        SUM(CASE WHEN is_present = 1 THEN 1 ELSE 0 END) as attended_classes
    FROM fact_attendance
    GROUP BY student_key
),
PerformanceStats AS (
    -- CTE to calculate average exam score per student
    SELECT 
        student_key,
        AVG(exam_score) as avg_exam_score
    FROM fact_performance
    GROUP BY student_key
)
SELECT 
    s.student_id,
    s.full_name,
    s.grade_level,
    ROUND(CAST(a.attended_classes AS REAL) / a.total_classes * 100, 2) as attendance_pct,
    ROUND(p.avg_exam_score, 2) as avg_exam_score,
    CASE 
        WHEN (CAST(a.attended_classes AS REAL) / a.total_classes) < 0.8 THEN 'High Risk: Attendance'
        WHEN p.avg_exam_score < 60 THEN 'High Risk: Academics'
        ELSE 'On Track'
    END as risk_status
FROM dim_students s
LEFT JOIN AttendanceStats a ON s.student_key = a.student_key
LEFT JOIN PerformanceStats p ON s.student_key = p.student_key
WHERE risk_status != 'On Track';

-- ==========================================
-- 4. ELT TRANSFORMATION LOGIC (Pseudo-Stored Procedure)
-- ==========================================

-- Upsert Logic for Dimensions (SCD Type 1 for simplicity)
INSERT INTO dim_students (student_id, full_name, date_of_birth, grade_level)
SELECT DISTINCT 
    Student_ID, 
    Full_Name, 
    Date_of_Birth, 
    Grade_Level
FROM stg_students
WHERE Student_ID NOT IN (SELECT student_id FROM dim_students);

-- Load Fact Attendance
INSERT INTO fact_attendance (student_key, date, subject, is_present)
SELECT 
    d.student_key,
    s.Date,
    s.Subject,
    CASE WHEN s.Attendance_Status = 'Present' THEN 1 ELSE 0 END
FROM stg_attendance s
JOIN dim_students d ON s.Student_ID = d.student_id;

-- Load Fact Performance
INSERT INTO fact_performance (student_key, subject, exam_score, homework_completion_pct)
SELECT 
    d.student_key,
    s.Subject,
    CAST(s.Exam_Score AS INTEGER),
    CAST(REPLACE(s.Homework_Completion_Pct, '%', '') AS REAL)
FROM stg_performance s
JOIN dim_students d ON s.Student_ID = d.student_id;

-- Load Fact Homework
INSERT INTO fact_homework (student_key, subject, assignment_name, due_date, status, grade_feedback, guardian_signature)
SELECT 
    d.student_key,
    s.Subject,
    s.Assignment_Name,
    s.Due_Date,
    s.Status,
    s.Grade_Feedback,
    CASE WHEN s.Guardian_Signature = 'Yes' THEN 1 ELSE 0 END
FROM stg_homework s
JOIN dim_students d ON s.Student_ID = d.student_id;

-- Load Fact Communication
INSERT INTO fact_communication (student_key, date, message_type, message_content)
SELECT 
    d.student_key,
    s.Date,
    s.Message_Type,
    s.Message_Content
FROM stg_communication s
JOIN dim_students d ON s.Student_ID = d.student_id;
