-- PostgreSQL에서는 FILTER로 교차표를 만든다
SELECT item_name,
 SUM(quantity) FILTER (WHERE color='진한색') AS dark,
 SUM(quantity) FILTER (WHERE color='파스텔') AS pastel,
 SUM(quantity) FILTER (WHERE color='흰색') AS white,
 SUM(quantity) AS total
FROM w11_demo.sales
GROUP BY item_name ORDER BY item_name;
