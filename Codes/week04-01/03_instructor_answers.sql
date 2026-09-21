-- E1: 모든 과목의 수강 인원
SELECT c.course_id, c.title,
       COUNT(t.student_id) AS n_student
FROM course AS c
LEFT JOIN takes AS t ON t.course_id = c.course_id
GROUP BY c.course_id, c.title
ORDER BY c.course_id;

-- E2: 성적이 입력된 과목이 두 개 이상
SELECT s.id, s.name,
       COUNT(t.score) AS n_scored,
       AVG(t.score) AS avg_score
FROM student AS s
LEFT JOIN takes AS t ON t.student_id = s.id
GROUP BY s.id, s.name
HAVING COUNT(t.score) >= 2
ORDER BY s.id;

-- E3: 성적 80점 이상 과목 수, 모든 학생 유지
SELECT s.id, s.name,
       COUNT(t.course_id) AS n_course
FROM student AS s
LEFT JOIN takes AS t
  ON t.student_id = s.id AND t.score >= 80
GROUP BY s.id, s.name
ORDER BY s.id;
