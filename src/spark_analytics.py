from pyspark.sql import SparkSession
from pyspark.sql.functions import col, avg, count, when

def run_spark_analytics():
    # Initialize Spark Session
    spark = SparkSession.builder \
        .appName("StudentPerformanceAnalytics") \
        .getOrCreate()

    print("Spark Session Created.")

    # Define paths (assuming running from project root)
    # Data is in ../data relative to the project root (student_360_pipeline)
    # Actually, the project root is /home/vrunda/Projects/data_engineer/student_360_pipeline
    # The data is in /home/vrunda/Projects/data_engineer/data
    # So relative path from project root is ../data
    source_data_dir = "../data" 
    
    # If running from src/ directory directly, we might need to adjust, but let's assume running from root via python src/script.py
    # To be safe, let's use absolute path based on this file's location
    import os
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) # student_360_pipeline/
    source_data_dir = os.path.join(os.path.dirname(base_dir), "data") # data_engineer/data/

    # Load DataFrames
    try:
        df_students = spark.read.csv(f"{source_data_dir}/students.csv", header=True, inferSchema=True)
        df_performance = spark.read.csv(f"{source_data_dir}/performance.csv", header=True, inferSchema=True)
        
        print("Data Loaded into Spark DataFrames.")

        # Transformation: Calculate Average Score per Grade Level
        # Join Students and Performance
        df_joined = df_students.join(df_performance, "Student_ID")

        # Aggregate
        df_report = df_joined.groupBy("Grade_Level") \
            .agg(
                avg("Exam_Score").alias("Avg_Exam_Score"),
                count("Student_ID").alias("Student_Count")
            ) \
            .orderBy("Avg_Exam_Score", ascending=False)

        print("Average Performance by Grade Level:")
        df_report.show()

        # Advanced: Identify Top Performers (Score > 90)
        df_top_performers = df_joined.filter(col("Exam_Score") > 90) \
            .select("Full_Name", "Grade_Level", "Subject", "Exam_Score")
        
        print("Top Performing Students:")
        df_top_performers.show(5)

    except Exception as e:
        print(f"Error in Spark job: {e}")
        print("Ensure the data files exist in the ../../data directory.")

    finally:
        spark.stop()

if __name__ == "__main__":
    run_spark_analytics()
