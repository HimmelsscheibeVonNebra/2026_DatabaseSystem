-- 학습된 트리의 일부 경로를 CASE로 표현
SELECT id,degree,income,
 CASE WHEN degree='석사' AND income<25000 THEN '나쁨'
      WHEN degree='석사' AND income<=75000 THEN '좋음'
      WHEN degree='석사' THEN '우수'
      ELSE '다른 분기 필요' END AS predicted
FROM w11_demo.customer_case ORDER BY id;
