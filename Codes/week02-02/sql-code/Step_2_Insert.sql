-- Step 2: Load the sample data
-- Run Step 1 first. Execute this whole script in auto-commit mode.
-- This script RESETS ALL ROWS in the five lab tables on every run.
-- Use only the lab database. Delete child rows before parent rows.
PRAGMA foreign_keys = ON;
BEGIN TRANSACTION;

DELETE FROM enroll;
DELETE FROM course;
DELETE FROM instructor;
DELETE FROM student;
DELETE FROM department;

-- Insert parent rows before rows that reference them.
INSERT INTO department (dept_name, building) VALUES
    ('Computer Science', 'Engineering Hall'),
    ('Mathematics', 'Science Hall'),
    ('Business', 'Business Hall'),
    ('Design', 'Arts Hall');

INSERT INTO student (id, name, dept_name, tot_cred) VALUES
    (1001, 'Minji Kim', 'Computer Science', 42),
    (1002, 'Seojun Lee', 'Mathematics', 30),
    (1003, 'Jiwoo Park', 'Computer Science', 18),
    (1004, 'Harin Choi', 'Business', 54),
    (1005, 'Doyun Jung', NULL, 0),
    (1006, 'Jimin Han', 'Mathematics', 35),
    (1007, 'Dohyun Kim', 'Design', 28);

INSERT INTO instructor (id, name, dept_name, salary) VALUES
    (2001, 'Professor Lee', 'Computer Science', 780),
    (2002, 'Professor Park', 'Mathematics', 760),
    (2003, 'Professor Choi', 'Business', 810),
    (2004, 'Professor Cho', 'Design', 690);

INSERT INTO course (code, title, dept_name, credits) VALUES
    ('CS101', 'Data Structures', 'Computer Science', 3),
    ('CS201', 'Databases', 'Computer Science', 4),
    ('MATH101', 'Calculus', 'Mathematics', 3),
    ('BUS101', 'Introduction to Business', 'Business', 3),
    ('DES100', 'Introduction to Design', 'Design', 2);

INSERT INTO enroll (student_id, course_code, grade) VALUES
    (1001, 'CS101', 'A'),
    (1001, 'CS201', 'B+'),
    (1002, 'MATH101', 'A-'),
    (1003, 'CS101', 'B'),
    (1004, 'BUS101', 'A'),
    (1004, 'CS201', 'A+'),
    (1005, 'MATH101', NULL),
    (1006, 'MATH101', 'C+'),
    (1007, 'DES100', 'B+');

COMMIT;

-- Expected row counts: 4, 7, 4, 5, 9.
SELECT 'department' AS table_name, COUNT(*) AS row_count FROM department
UNION ALL SELECT 'student', COUNT(*) FROM student
UNION ALL SELECT 'instructor', COUNT(*) FROM instructor
UNION ALL SELECT 'course', COUNT(*) FROM course
UNION ALL SELECT 'enroll', COUNT(*) FROM enroll;
