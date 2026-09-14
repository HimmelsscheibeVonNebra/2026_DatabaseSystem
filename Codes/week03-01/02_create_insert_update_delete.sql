-- 파일 전체를 순서대로 실행하거나, STEP 단위로 실행하세요.
-- practice_student만 변경합니다. 다시 시작하려면 STEP 1부터 실행하세요.
PRAGMA foreign_keys = ON;

-- STEP 1. CREATE TABLE: 연습용 테이블 생성 (기존 연습 내용은 삭제)
DROP TABLE IF EXISTS practice_student;
CREATE TABLE practice_student (
    student_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    department_id INTEGER REFERENCES department(department_id),
    entry_year INTEGER NOT NULL CHECK (entry_year BETWEEN 2000 AND 2100),
    active INTEGER NOT NULL DEFAULT 1 CHECK (active IN (0, 1))
) STRICT;
SELECT name, sql FROM sqlite_schema WHERE name = 'practice_student';

-- STEP 2. INSERT: active 생략 시 DEFAULT 1; NULL은 따옴표 없이 입력
INSERT INTO practice_student (student_id, name, email, department_id, entry_year) VALUES
    (9001, 'Kim Practice', 'practice1@example.edu', 1, 2026),
    (9002, 'Lee Practice', 'practice2@example.edu', 2, 2025),
    (9003, 'Park Practice', 'practice3@example.edu', NULL, 2026);
SELECT * FROM practice_student ORDER BY student_id; -- 3행, active 모두 1

-- STEP 3. UPDATE: 먼저 같은 WHERE로 대상 확인 → 수정 → 결과 확인
SELECT * FROM practice_student WHERE student_id = 9002;
UPDATE practice_student SET department_id = 1, active = 0 WHERE student_id = 9002;
SELECT * FROM practice_student WHERE student_id = 9002; -- department_id=1, active=0

-- STEP 4. DELETE: 학번 9003만 삭제
SELECT * FROM practice_student WHERE student_id = 9003;
DELETE FROM practice_student WHERE student_id = 9003;
SELECT * FROM practice_student ORDER BY student_id; -- 9001, 9002만 남음

-- STEP 5. WHERE 없는 UPDATE가 전체 행에 적용됨을 관찰
-- BEGIN~ROLLBACK을 한 연결에서 순서대로 실행하세요.
BEGIN;
UPDATE practice_student SET active = 0;
SELECT * FROM practice_student ORDER BY student_id; -- 두 학생 모두 active=0
ROLLBACK;
SELECT * FROM practice_student ORDER BY student_id; -- 9001은 1, 9002는 0으로 복구
-- ROLLBACK은 아직 COMMIT하지 않은 이 트랜잭션의 변경만 취소합니다.
