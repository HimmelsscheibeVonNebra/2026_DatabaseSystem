-- 의도적으로 실패하는 예제입니다. 전체 실행하지 말고 E 블록 하나씩 실행하세요.
-- 먼저 트랜잭션 밖에서 다음 PRAGMA를 실행하세요. 결과 1을 확인해야 E04가 실패합니다.
PRAGMA foreign_keys = ON;
PRAGMA foreign_keys;

-- E01: PRIMARY KEY 중복
-- 예상 오류 유형: UNIQUE constraint failed (도구·버전에 따라 문구는 다를 수 있음)
INSERT INTO student VALUES (1001, 'Duplicate', 'dup@example.edu', 1, 2026, 1);

-- E02: NOT NULL 위반
-- 예상 오류 유형: NOT NULL constraint failed (도구·버전에 따라 문구는 다를 수 있음)
INSERT INTO student VALUES (9102, NULL, 'e02@example.edu', 1, 2026, 1);

-- E03: UNIQUE 이메일 중복
-- 예상 오류 유형: UNIQUE constraint failed (도구·버전에 따라 문구는 다를 수 있음)
INSERT INTO student VALUES (9103, 'Email Test', 'minseo@example.edu', 1, 2026, 1);

-- E04: 존재하지 않는 학과 FK
-- 예상 오류 유형: FOREIGN KEY constraint failed (도구·버전에 따라 문구는 다를 수 있음)
INSERT INTO student VALUES (9104, 'FK Test', 'e04@example.edu', 99, 2026, 1);

-- E05: CHECK: active는 0 또는 1
-- 예상 오류 유형: CHECK constraint failed (도구·버전에 따라 문구는 다를 수 있음)
INSERT INTO student VALUES (9105, 'Check Test', 'e05@example.edu', 1, 2026, 2);

-- E06: STRICT: 정수 열에 변환 불가능한 문자열
-- 예상 오류 유형: cannot store TEXT value (도구·버전에 따라 문구는 다를 수 있음)
INSERT INTO student VALUES (9106, 'Type Test', 'e06@example.edu', 1, 'hello', 1);

-- E07: 존재하지 않는 열
-- 예상 오류 유형: no such column (도구·버전에 따라 문구는 다를 수 있음)
SELECT student_name FROM student;

-- E08: SELECT 키워드 오타
-- 예상 오류 유형: syntax error (도구·버전에 따라 문구는 다를 수 있음)
SELEC name FROM student;
