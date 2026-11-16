-- 차원을 조인해 품목을 범주로 묶는다
SELECT d.category, SUM(s.quantity) AS qty
FROM w11_demo.sales s
JOIN w11_demo.item_dim d USING(item_name)
GROUP BY d.category
ORDER BY d.category;
