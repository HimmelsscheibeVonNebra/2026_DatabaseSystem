-- Step 1: Create the database schema
-- Open test.db in DBeaver and select it as the SQL editor connection.
-- Use auto-commit mode with no pending transaction for these scripts.
-- Execute this entire script, then Step_2_Insert.sql, then Step_3_Queries.sql.
-- The supplied test.db already contains the Step 2 sample data.
-- Foreign-key enforcement must be enabled on every new connection.
PRAGMA foreign_keys = ON;

BEGIN TRANSACTION;

CREATE TABLE IF NOT EXISTS department (
    dept_name TEXT PRIMARY KEY,
    building TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS student (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    dept_name TEXT,
    tot_cred INTEGER NOT NULL DEFAULT 0,
    FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE IF NOT EXISTS instructor (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    dept_name TEXT,
    salary INTEGER NOT NULL,
    FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE IF NOT EXISTS course (
    code TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    dept_name TEXT NOT NULL,
    credits INTEGER NOT NULL,
    FOREIGN KEY (dept_name) REFERENCES department(dept_name)
);

CREATE TABLE IF NOT EXISTS enroll (
    student_id INTEGER NOT NULL,
    course_code TEXT NOT NULL,
    grade TEXT,
    PRIMARY KEY (student_id, course_code),
    FOREIGN KEY (student_id) REFERENCES student(id),
    FOREIGN KEY (course_code) REFERENCES course(code)
);

COMMIT;

-- Expected: course, department, enroll, instructor, student (5 tables).
SELECT name FROM sqlite_schema WHERE type = 'table' ORDER BY name;
