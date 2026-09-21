-- 00_schema_data.sql로 만든 전용 DB에서 실행합니다.

-- Q01: 학생
SELECT id, name
FROM student
ORDER BY id;

-- Q02: 수강
SELECT student_id, course_id, score
FROM takes ORDER BY student_id, course_id;

-- Q03: 과목
SELECT course_id, title, credits
FROM course ORDER BY course_id;

-- Q04: 조건 없는 조합
SELECT COUNT(*) AS pairs
FROM student AS s CROSS JOIN takes AS t;

-- Q05: INNER JOIN
SELECT s.id, s.name, t.course_id, t.score
FROM student AS s
JOIN takes AS t ON t.student_id = s.id
ORDER BY s.id, t.course_id;

-- Q06: 수강한 학생 한 번씩
SELECT DISTINCT s.id, s.name
FROM student AS s
JOIN takes AS t ON t.student_id = s.id
ORDER BY s.id;

-- Q07: 세 테이블 JOIN
SELECT s.id, s.name, c.title, t.score
FROM student AS s
JOIN takes AS t ON t.student_id = s.id
JOIN course AS c ON c.course_id = t.course_id
ORDER BY s.id, c.course_id;

-- Q08: LEFT JOIN
SELECT s.id, s.name, t.course_id, t.score
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
ORDER BY s.id, t.course_id;

-- Q09: 수강하지 않은 학생
SELECT s.id, s.name
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
WHERE t.student_id IS NULL
ORDER BY s.id;

-- Q10: LEFT JOIN 연결 유지
SELECT s.id, s.name, c.title, t.score
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
LEFT JOIN course AS c ON c.course_id = t.course_id
ORDER BY s.id, c.course_id;

-- Q11: ON의 점수 조건
SELECT s.id, s.name, t.course_id, t.score
FROM student AS s
LEFT JOIN takes AS t
  ON t.student_id = s.id AND t.score >= 80
ORDER BY s.id, t.course_id;

-- Q12: WHERE의 점수 조건
SELECT s.id, s.name, t.course_id, t.score
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
WHERE t.score >= 80
ORDER BY s.id, t.course_id;

-- Q13: NATURAL JOIN의 공통 열 없음
SELECT COUNT(*) AS pairs
FROM student NATURAL JOIN takes;

-- Q14: USING으로 열 지정
SELECT t.student_id, c.title, t.score
FROM takes AS t
JOIN course AS c USING (course_id)
ORDER BY t.student_id, c.course_id;

-- Q15: 전체 수강 집계
SELECT COUNT(*) AS n_take,
       COUNT(score) AS n_scored,
       SUM(score) AS sum_score,
       AVG(score) AS avg_score,
       MIN(score) AS min_score,
       MAX(score) AS max_score
FROM takes;

-- Q16: 학생별 집계
SELECT student_id,
       COUNT(*) AS n_course,
       COUNT(score) AS n_scored,
       AVG(score) AS avg_score
FROM takes
GROUP BY student_id
ORDER BY student_id;

-- Q17: LEFT JOIN과 COUNT 비교
SELECT s.id, s.name,
       COUNT(*) AS joined_rows,
       COUNT(t.course_id) AS n_course,
       COUNT(t.score) AS n_scored
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
GROUP BY s.id, s.name
ORDER BY s.id;

-- Q18: WHERE 뒤 GROUP BY와 HAVING
SELECT student_id,
       COUNT(*) AS n_course,
       AVG(score) AS avg_score
FROM takes
WHERE score >= 80
GROUP BY student_id
HAVING COUNT(*) >= 2
ORDER BY student_id;

-- Q19: 두 과목 이상 수강한 학생
SELECT s.id, s.name,
       COUNT(t.course_id) AS n_course
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(t.course_id) >= 2
ORDER BY s.id;

-- Q20: 학생별 수강 현황
SELECT s.id, s.name,
       COUNT(t.course_id) AS n_course,
       COUNT(t.score) AS n_scored,
       COALESCE(SUM(c.credits), 0) AS credits,
       ROUND(AVG(t.score), 1) AS avg_score
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
LEFT JOIN course AS c ON c.course_id = t.course_id
GROUP BY s.id, s.name
ORDER BY s.id;

-- Q21: 모든 과목의 수강 인원
SELECT c.course_id, c.title,
       COUNT(t.student_id) AS n_student
FROM course AS c
LEFT JOIN takes AS t ON t.course_id = c.course_id
GROUP BY c.course_id, c.title
ORDER BY c.course_id;

-- Q22: 성적이 입력된 과목이 두 개 이상
SELECT s.id, s.name,
       COUNT(t.score) AS n_scored,
       AVG(t.score) AS avg_score
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(t.score) >= 2
ORDER BY s.id;

-- Q23: 성적 80점 이상 과목 수, 모든 학생 유지
SELECT s.id, s.name,
       COUNT(t.course_id) AS n_course
FROM student AS s
LEFT JOIN takes AS t
  ON t.student_id = s.id AND t.score >= 80
GROUP BY s.id, s.name
ORDER BY s.id;

-- Q24: 입력 성적이 없는 집계
SELECT COUNT(*) AS n_take, COUNT(score) AS n_scored,
       SUM(score) AS sum_score, AVG(score) AS avg_score
FROM takes WHERE student_id = 1002;
