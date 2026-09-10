-- Step 4: Clear all sample data
-- This script DELETES ALL ROWS in the five lab tables.
-- Table definitions remain available for the next exercise.
-- Use only the lab database, after Step 1 has created the tables.
-- Execute the entire script in auto-commit mode with no pending transaction.
-- Run Step_2_Insert.sql afterward to restore the sample data.
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

-- Delete child rows before the parent rows they reference.
DELETE FROM enroll;
DELETE FROM course;
DELETE FROM instructor;
DELETE FROM student;
DELETE FROM department;

COMMIT;

-- Expected: all five row counts are 0.
SELECT 'department' AS table_name, COUNT(*) AS row_count FROM department
UNION ALL SELECT 'student', COUNT(*) FROM student
UNION ALL SELECT 'instructor', COUNT(*) FROM instructor
UNION ALL SELECT 'course', COUNT(*) FROM course
UNION ALL SELECT 'enroll', COUNT(*) FROM enroll;

-- Expected: no foreign-key violations.
PRAGMA foreign_key_check;
