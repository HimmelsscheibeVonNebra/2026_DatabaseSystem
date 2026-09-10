-- Step 3: Query and modify the sample data
-- Run after Step 2, or use the supplied test.db directly.
-- Run SELECT statements individually to inspect each result in DBeaver.
-- For the modification exercise, execute BEGIN through ROLLBACK together.
PRAGMA foreign_keys = ON;

-- Query 1: List all students. Expected: 7 rows.
SELECT s.id, s.name, s.dept_name, s.tot_cred
FROM student AS s
ORDER BY s.id;

-- Query 2: Filter by department. Expected IDs: 1001, 1003.
SELECT id, name, tot_cred
FROM student
WHERE dept_name = 'Computer Science'
ORDER BY id;

-- Query 3: Find missing departments. Use IS NULL, not = NULL.
-- Expected: 1005, Doyun Jung.
SELECT id, name FROM student WHERE dept_name IS NULL;

-- Query 4: Find students with at least 40 credits. Expected: 1004, 1001.
SELECT id, name, tot_cred
FROM student WHERE tot_cred >= 40
ORDER BY tot_cred DESC, name;

-- Query 5: Count students by department, including the NULL group.
-- Expected: Computer Science 2, Mathematics 2, NULL 1, Business 1, Design 1.
SELECT dept_name, COUNT(*) AS student_cnt
FROM student GROUP BY dept_name
ORDER BY student_cnt DESC, dept_name;

-- Query 6: Average credits. Expected: NULL 0, Business 54,
-- Computer Science 30, Design 28, Mathematics 32.5.
SELECT dept_name, AVG(tot_cred) AS avg_cred
FROM student GROUP BY dept_name ORDER BY dept_name;

-- Query 7: Join students, enrollments, courses, and departments.
-- Expected: 9 rows. The building belongs to the course department.
SELECT s.id, s.name, c.title, d.building
FROM student AS s
JOIN enroll AS e ON s.id = e.student_id
JOIN course AS c ON e.course_code = c.code
JOIN department AS d ON c.dept_name = d.dept_name
ORDER BY s.id, c.code;

-- Queries 8-10: Check the baseline. Expected: 7 students, 4 departments.
SELECT COUNT(*) AS student_cnt FROM student;
SELECT COUNT(*) AS dept_cnt FROM department;
SELECT name, dept_name FROM student ORDER BY id;

-- Queries 11-12: Inspect the other sample tables (4 and 5 rows).
SELECT id, name, dept_name, salary FROM instructor ORDER BY id;
SELECT code, title, dept_name, credits FROM course ORDER BY code;

-- Modification exercise: INSERT -> UPDATE -> DELETE -> ROLLBACK.
-- Execute the complete block. ROLLBACK restores the initial sample data.
BEGIN TRANSACTION;

INSERT INTO student (id, name, dept_name, tot_cred)
VALUES (1008, 'Yejin Shin', 'Mathematics', 31);
-- Expected: 8 students, including the new student.
SELECT COUNT(*) AS student_count_after_insert FROM student;
SELECT * FROM student WHERE id = 1008;

UPDATE student SET tot_cred = 38 WHERE id = 1003;
-- Expected: 1003, Jiwoo Park, 38.
SELECT id, name, tot_cred FROM student WHERE id = 1003;

DELETE FROM student WHERE id = 1008;
-- Expected: 0 matching rows. This student has no enrollments.
SELECT COUNT(*) AS deleted_student_count FROM student WHERE id = 1008;

ROLLBACK;

-- Expected after rollback: 7 students; student 1003 has 18 credits.
SELECT COUNT(*) AS student_count_after_rollback FROM student;
SELECT id, tot_cred FROM student WHERE id = 1003;

-- Database checks: foreign_keys = 1; no violations; integrity_check = ok.
PRAGMA foreign_keys;
PRAGMA foreign_key_check;
PRAGMA integrity_check;
