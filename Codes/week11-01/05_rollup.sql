SELECT d.category, s.item_name,
 SUM(s.quantity) AS qty,
 GROUPING(d.category,s.item_name) AS g
FROM w11_demo.sales s
JOIN w11_demo.item_dim d USING(item_name)
GROUP BY ROLLUP(d.category,s.item_name)
ORDER BY g,d.category,s.item_name;
