-- 각 Q 블록을 선택하여 하나씩 실행하세요. ORDER BY가 없으면 행 순서는 보장되지 않습니다.
PRAGMA foreign_keys = ON;

-- Q01: 전체 학생 조회: 학번 순서로 8행
SELECT * FROM student ORDER BY student_id;

-- Q02: 필요한 열과 별칭: 학번·이름만 조회
SELECT student_id AS 학번, name AS 이름 FROM student ORDER BY student_id;

-- Q03: WHERE: 컴퓨터공학과(1) 학생
SELECT student_id, name FROM student WHERE department_id = 1 ORDER BY student_id;

-- Q04: 비교: 2024년 이후 입학생
SELECT student_id, name, entry_year FROM student WHERE entry_year >= 2024 ORDER BY student_id;

-- Q05: AND: 컴퓨터공학과이면서 2023년 이후 입학
SELECT student_id, name FROM student WHERE department_id = 1 AND entry_year >= 2023 ORDER BY student_id;

-- Q06: 괄호·OR: 학과 1 또는 2이며 2024년 입학
SELECT student_id, name FROM student WHERE (department_id = 1 OR department_id = 2) AND entry_year = 2024 ORDER BY student_id;

-- Q07: IN: 수학과(2) 또는 물리학과(4)
SELECT student_id, name FROM student WHERE department_id IN (2, 4) ORDER BY student_id;

-- Q08: BETWEEN: 2022~2023년 입학 (양 끝 포함)
SELECT student_id, name, entry_year FROM student WHERE entry_year BETWEEN 2022 AND 2023 ORDER BY student_id;

-- Q09: LIKE: Kim으로 시작하는 이름 (%는 0개 이상의 문자)
SELECT student_id, name FROM student WHERE name LIKE 'Kim%' ORDER BY student_id;

-- Q10: LIKE: CS 다음 정확히 세 글자인 과목 코드 (_는 문자 한 개)
SELECT course_id, title FROM course WHERE course_id LIKE 'CS___' ORDER BY course_id;

-- Q11: DISTINCT: 입학 연도 중복 제거
SELECT DISTINCT entry_year FROM student ORDER BY entry_year;

-- Q12: ORDER BY: 최신 입학 연도 우선, 같은 연도는 학번 오름차순
SELECT student_id, name, entry_year FROM student ORDER BY entry_year DESC, student_id ASC;

-- Q13: LIMIT: 위 정렬의 처음 3명
SELECT student_id, name, entry_year FROM student ORDER BY entry_year DESC, student_id ASC LIMIT 3;

-- Q14: 계산식: 과목별 주당 수업시간(1학점=50분 가정)
SELECT course_id, credits, credits * 50 AS weekly_minutes FROM course ORDER BY course_id;

-- Q15: NULL 맛보기: 소속 학과가 없는 학생
SELECT student_id, name FROM student WHERE department_id IS NULL ORDER BY student_id;

-- Q16: NULL 비교 실수: 오류는 없지만 0행. Q15와 비교
SELECT student_id, name FROM student WHERE department_id = NULL ORDER BY student_id;

-- Q17: 부정 조건: 현재 재학하지 않는 학생
SELECT student_id, name FROM student WHERE active <> 1 ORDER BY student_id;

-- Q18: 조건과 정렬 조합: 3학점 이상 과목, 학점 내림차순·코드 오름차순
SELECT course_id, title, credits FROM course WHERE credits >= 3 ORDER BY credits DESC, course_id;
