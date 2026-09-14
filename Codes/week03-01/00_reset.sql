-- 3주차 전용 DB에서 실행하세요. 기존 실습 테이블과 변경 내용을 초기화합니다.
-- SQLite 3.37.0 이상 필요 (STRICT 테이블 사용). 데이터는 모두 가상입니다.
PRAGMA foreign_keys = ON;

BEGIN;
DROP TABLE IF EXISTS practice_student;
DROP TABLE IF EXISTS enrollment;
DROP TABLE IF EXISTS course;
DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS department;

CREATE TABLE department (
    department_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    building TEXT NOT NULL,
    budget REAL NOT NULL CHECK (budget >= 0)
) STRICT;

CREATE TABLE student (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department_id INTEGER,
    entry_year INTEGER NOT NULL CHECK (entry_year BETWEEN 2000 AND 2100),
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1)),
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON UPDATE CASCADE
        ON DELETE SET NULL
) STRICT;

CREATE TABLE course (
    course_id TEXT PRIMARY KEY NOT NULL,
    title TEXT NOT NULL,
    credits INTEGER NOT NULL CHECK (credits BETWEEN 1 AND 6),
    department_id INTEGER NOT NULL,
    FOREIGN KEY (department_id)
        REFERENCES department(department_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) STRICT;

CREATE TABLE enrollment (
    student_id INTEGER NOT NULL,
    course_id TEXT NOT NULL,
    semester TEXT NOT NULL,
    grade TEXT,
    PRIMARY KEY (student_id, course_id, semester),
    FOREIGN KEY (student_id)
        REFERENCES student(student_id)
        ON DELETE CASCADE,
    FOREIGN KEY (course_id)
        REFERENCES course(course_id)
        ON DELETE RESTRICT,
    CHECK (grade IS NULL OR grade IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F'))
) STRICT;

INSERT INTO department (department_id, name, building, budget) VALUES
    (1, 'Computer Science', 'Engineering A', 1200000),
    (2, 'Mathematics', 'Science Hall', 850000),
    (3, 'Business', 'Business Hall', 950000),
    (4, 'Physics', 'Science Hall', 780000);

INSERT INTO student
    (student_id, name, email, department_id, entry_year, active)
VALUES
    (1001, 'Kim Minseo', 'minseo@example.edu', 1, 2024, 1),
    (1002, 'Lee Jihoon', 'jihoon@example.edu', 1, 2023, 1),
    (1003, 'Park Soyeon', 'soyeon@example.edu', 2, 2024, 1),
    (1004, 'Choi Junho', 'junho@example.edu', 3, 2022, 1),
    (1005, 'Jung Haeun', 'haeun@example.edu', 1, 2022, 1),
    (1006, 'Han Yujin', 'yujin@example.edu', 4, 2023, 1),
    (1007, 'Yoon Seojun', 'seojun@example.edu', 2, 2021, 0),
    (1008, 'Lim Chaewon', 'chaewon@example.edu', NULL, 2025, 1);

INSERT INTO course (course_id, title, credits, department_id) VALUES
    ('CS101', 'Introduction to Programming', 3, 1),
    ('CS202', 'Data Structures', 3, 1),
    ('CS301', 'Database Systems', 3, 1),
    ('CS401', 'Operating Systems', 3, 1),
    ('MA101', 'Calculus', 4, 2),
    ('MA220', 'Discrete Mathematics', 3, 2),
    ('BA210', 'Principles of Management', 2, 3),
    ('PH101', 'General Physics', 3, 4);

INSERT INTO enrollment (student_id, course_id, semester, grade) VALUES
    (1001, 'CS101', '2025-1', 'A'),
    (1001, 'MA220', '2025-1', 'B+'),
    (1001, 'CS301', '2025-2', NULL),
    (1002, 'CS202', '2024-2', 'A+'),
    (1002, 'CS301', '2025-1', 'A'),
    (1003, 'MA101', '2024-2', 'B'),
    (1003, 'CS101', '2025-1', 'B+'),
    (1004, 'BA210', '2024-1', 'A'),
    (1005, 'CS202', '2024-1', 'B+'),
    (1005, 'CS301', '2025-1', 'A+'),
    (1006, 'PH101', '2024-2', 'A'),
    (1006, 'MA101', '2025-1', 'B'),
    (1007, 'MA220', '2023-2', 'C+');


COMMIT;
