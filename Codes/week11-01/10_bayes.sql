-- 본문 두 후보만 비교: 전체 클래스 확률은 아님
SELECT class,prior,likelihood,
 prior*likelihood AS score,
 ROUND(prior*likelihood /
 SUM(prior*likelihood) OVER(),2) AS candidate_prob
FROM w11_demo.bayes_likelihood
ORDER BY score DESC;
