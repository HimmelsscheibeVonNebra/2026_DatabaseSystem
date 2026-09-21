-- Week 04 Class 01 전용 새 DB에서 실행합니다.
-- Week 4-2 실습과 동일한 학생 5명, 과목 4개, 수강 5건입니다.
PRAGMA foreign_keys = ON;
BEGIN;
CREATE TABLE student (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL
);
CREATE TABLE course (
  course_id TEXT PRIMARY KEY NOT NULL,
  title TEXT NOT NULL,
  credits INTEGER NOT NULL CHECK (credits > 0)
);
CREATE TABLE takes (
  student_id INTEGER NOT NULL REFERENCES student(id),
  course_id TEXT NOT NULL REFERENCES course(course_id),
  score INTEGER CHECK (score BETWEEN 0 AND 100),
  PRIMARY KEY (student_id, course_id)
);
INSERT INTO student VALUES
  (1001,'김민지'), (1002,'이서준'), (1003,'박지우'),
  (1004,'최하린'), (1005,'정도윤');
INSERT INTO course VALUES
  ('CS101','데이터베이스',3), ('CS102','운영체제',3),
  ('MA101','이산수학',2), ('BA101','경영통계',2);
INSERT INTO takes VALUES
  (1001,'CS101',90), (1001,'CS102',80),
  (1002,'MA101',NULL), (1003,'CS101',95), (1003,'MA101',70);
COMMIT;
