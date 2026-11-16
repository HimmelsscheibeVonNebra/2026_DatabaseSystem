WITH t AS (
 SELECT tx,bool_or(item='바지') AS a,
           bool_or(item='벨트') AS b
 FROM w11_demo.basket GROUP BY tx)
SELECT ROUND(AVG((a AND b)::int),3) AS support,
 ROUND(SUM((a AND b)::int)::numeric/SUM(a::int),3) AS confidence,
 ROUND(AVG((a AND b)::int)/(AVG(a::int)*AVG(b::int)),3) AS lift
FROM t;
