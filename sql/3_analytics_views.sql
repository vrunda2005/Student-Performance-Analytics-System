-- ==========================================
-- 3. ANALYTICS & VIEWS (Data Mart Layer)
-- ==========================================

-- 3.1 VIEW: Student Risk Monitor (Enhanced)
-- Rules: Attendance < 80% OR Exam Average < 60 OR < 50% Homework Completion
DROP VIEW IF EXISTS v_student_risk_monitor;
CREATE VIEW v_student_risk_monitor AS
WITH AttendanceStats AS (
    SELECT 
        student_key,
        COUNT(*) as total_classes,
        SUM(CASE WHEN is_present = 1 THEN 1 ELSE 0 END) as attended_classes
    FROM fact_attendance
    GROUP BY student_key
),
PerformanceStats AS (
    SELECT 
        student_key,
        AVG(exam_score) as avg_exam_score,
        AVG(homework_completion_pct) as avg_hw_pct
    FROM fact_performance
    GROUP BY student_key
)
SELECT 
    s.student_id,
    s.full_name,
    s.grade_level,
    ROUND(CAST(a.attended_classes AS REAL) / a.total_classes * 100, 2) as attendance_pct,
    ROUND(p.avg_exam_score, 2) as avg_exam_score,
    ROUND(p.avg_hw_pct, 2) as avg_hw_pct,
    CASE 
        WHEN (CAST(a.attended_classes AS REAL) / a.total_classes) < 0.8 THEN 'High Risk: Attendance'
        WHEN p.avg_exam_score < 60 THEN 'High Risk: Academics'
        WHEN p.avg_hw_pct < 50 THEN 'High Risk: Homework'
        ELSE 'On Track'
    END as risk_status
FROM dim_students s
LEFT JOIN AttendanceStats a ON s.student_key = a.student_key
LEFT JOIN PerformanceStats p ON s.student_key = p.student_key
WHERE risk_status != 'On Track';

-- 3.2 VIEW: Monthly Student Summary (New Aggregation)
-- Aggregates performance and attendance by Student and Month
DROP VIEW IF EXISTS agg_student_monthly;
CREATE VIEW agg_student_monthly AS
SELECT 
    s.student_key,
    s.full_name,
    strftime('%Y-%m', a.date) as month, -- Extract YYYY-MM from Date
    COUNT(*) as total_classes,
    SUM(CASE WHEN a.is_present = 1 THEN 1 ELSE 0 END) as days_present,
    ROUND(CAST(SUM(CASE WHEN a.is_present = 1 THEN 1 ELSE 0 END) AS REAL) / COUNT(*) * 100, 1) as monthly_attendance_pct
FROM fact_attendance a
JOIN dim_students s ON a.student_key = s.student_key
GROUP BY s.student_key, s.full_name, strftime('%Y-%m', a.date);
