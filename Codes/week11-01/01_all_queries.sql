-- 차원을 조인해 품목을 범주로 묶는다
SELECT d.category, SUM(s.quantity) AS qty
FROM w11_demo.sales s
JOIN w11_demo.item_dim d USING(item_name)
GROUP BY d.category
ORDER BY d.category;

-- PostgreSQL에서는 FILTER로 교차표를 만든다
SELECT item_name,
 SUM(quantity) FILTER (WHERE color='진한색') AS dark,
 SUM(quantity) FILTER (WHERE color='파스텔') AS pastel,
 SUM(quantity) FILTER (WHERE color='흰색') AS white,
 SUM(quantity) AS total
FROM w11_demo.sales
GROUP BY item_name ORDER BY item_name;

SELECT item_name, SUM(quantity) AS qty
FROM w11_demo.sales
WHERE size='L'
GROUP BY item_name
ORDER BY item_name;

SELECT item_name, color, size, quantity
FROM w11_demo.sales
WHERE size='L' AND color='흰색'
  AND item_name IN ('셔츠','바지')
ORDER BY item_name;

SELECT d.category, s.item_name,
 SUM(s.quantity) AS qty,
 GROUPING(d.category,s.item_name) AS g
FROM w11_demo.sales s
JOIN w11_demo.item_dim d USING(item_name)
GROUP BY ROLLUP(d.category,s.item_name)
ORDER BY g,d.category,s.item_name;

SELECT s.item_name,s.size,SUM(s.quantity) AS qty
FROM w11_demo.sales s
JOIN w11_demo.item_dim d USING(item_name)
WHERE d.category='여성복'
GROUP BY s.item_name,s.size
ORDER BY s.item_name,s.size;

SELECT item_name, color, SUM(quantity) AS qty,
 GROUPING(item_name,color) AS g
FROM w11_demo.sales
GROUP BY CUBE(item_name,color)
ORDER BY g DESC,item_name,color;

SELECT item_name,size,SUM(quantity) AS qty,
 GROUPING(item_name,size) AS g
FROM w11_demo.sales
GROUP BY GROUPING SETS ((item_name),(size),())
ORDER BY g,item_name,size;

-- 학습된 트리의 일부 경로를 CASE로 표현
SELECT id,degree,income,
 CASE WHEN degree='석사' AND income<25000 THEN '나쁨'
      WHEN degree='석사' AND income<=75000 THEN '좋음'
      WHEN degree='석사' THEN '우수'
      ELSE '다른 분기 필요' END AS predicted
FROM w11_demo.customer_case ORDER BY id;

-- 본문 두 후보만 비교: 전체 클래스 확률은 아님
SELECT class,prior,likelihood,
 prior*likelihood AS score,
 ROUND(prior*likelihood /
 SUM(prior*likelihood) OVER(),2) AS candidate_prob
FROM w11_demo.bayes_likelihood
ORDER BY score DESC;

-- 설명용 경계 f(x)=0.1*income-5 (income 단위: 천)
SELECT id,income,
 0.1*(income/1000.0)-5 AS margin_score,
 CASE WHEN 0.1*(income/1000.0)-5>=0
      THEN 'B' ELSE 'A' END AS predicted
FROM w11_demo.customer_case ORDER BY id;

-- 설명용 한 뉴런: z=0.1*x-5, 출력=sigmoid(z)
SELECT id,income,
 ROUND((1.0/(1+EXP(-(0.1*income/1000.0-5))))
       ::numeric,3) AS sigmoid_output
FROM w11_demo.customer_case ORDER BY id;

SELECT ROUND(regr_intercept(y,x)::numeric,2) AS intercept,
 ROUND(regr_slope(y,x)::numeric,2) AS slope,
 ROUND((regr_intercept(y,x)+7*regr_slope(y,x))
       ::numeric,2) AS prediction_x7
FROM w11_demo.ad_sales;

SELECT
 ROUND(SUM(n) FILTER(WHERE actual=predicted)::numeric
       /SUM(n),3) AS accuracy,
 ROUND(SUM(n) FILTER(WHERE actual=1 AND predicted=1)::numeric
       /SUM(n) FILTER(WHERE predicted=1),3) AS precision,
 ROUND(SUM(n) FILTER(WHERE actual=1 AND predicted=1)::numeric
       /SUM(n) FILTER(WHERE actual=1),3) AS recall
FROM w11_demo.prediction;

WITH t AS (
 SELECT tx,bool_or(item='바지') AS a,
           bool_or(item='벨트') AS b
 FROM w11_demo.basket GROUP BY tx)
SELECT ROUND(AVG((a AND b)::int),3) AS support,
 ROUND(SUM((a AND b)::int)::numeric/SUM(a::int),3) AS confidence,
 ROUND(AVG((a AND b)::int)/(AVG(a::int)*AVG(b::int)),3) AS lift
FROM t;

-- 한 번의 배정 단계: 반복 학습의 완성 결과가 아님
SELECT DISTINCT ON (p.id) p.id,c.id AS cluster_id,
 (p.x-c.x)^2+(p.y-c.y)^2 AS distance_sq
FROM w11_demo.customer_point p
CROSS JOIN w11_demo.center c
ORDER BY p.id,distance_sq,c.id;

-- 긍정·부정 단어 사전을 조인하는 단순 예
SELECT r.id,r.body,COALESCE(SUM(l.score),0) AS score
FROM w11_demo.review r
LEFT JOIN w11_demo.lexicon l
 ON r.body LIKE '%'||l.word||'%'
GROUP BY r.id,r.body ORDER BY r.id;

-- 활성 배치=2: offset<=1, 실시간=offset>1
SELECT 'batch' AS path,SUM(b.amount) AS amount
FROM w11_demo.batch_sales b
JOIN w11_demo.serving_head h ON b.batch_id=h.active_batch_id
UNION ALL
SELECT 'speed',SUM(amount) FROM w11_demo.speed_tail
UNION ALL
SELECT 'combined',SUM(amount) FROM w11_demo.sales_current;
