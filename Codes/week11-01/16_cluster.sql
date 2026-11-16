-- 한 번의 배정 단계: 반복 학습의 완성 결과가 아님
SELECT DISTINCT ON (p.id) p.id,c.id AS cluster_id,
 (p.x-c.x)^2+(p.y-c.y)^2 AS distance_sq
FROM w11_demo.customer_point p
CROSS JOIN w11_demo.center c
ORDER BY p.id,distance_sq,c.id;
