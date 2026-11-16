-- 긍정·부정 단어 사전을 조인하는 단순 예
SELECT r.id,r.body,COALESCE(SUM(l.score),0) AS score
FROM w11_demo.review r
LEFT JOIN w11_demo.lexicon l
 ON r.body LIKE '%'||l.word||'%'
GROUP BY r.id,r.body ORDER BY r.id;
