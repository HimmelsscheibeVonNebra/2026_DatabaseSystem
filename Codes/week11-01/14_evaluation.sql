SELECT
 ROUND(SUM(n) FILTER(WHERE actual=predicted)::numeric
       /SUM(n),3) AS accuracy,
 ROUND(SUM(n) FILTER(WHERE actual=1 AND predicted=1)::numeric
       /SUM(n) FILTER(WHERE predicted=1),3) AS precision,
 ROUND(SUM(n) FILTER(WHERE actual=1 AND predicted=1)::numeric
       /SUM(n) FILTER(WHERE actual=1),3) AS recall
FROM w11_demo.prediction;
