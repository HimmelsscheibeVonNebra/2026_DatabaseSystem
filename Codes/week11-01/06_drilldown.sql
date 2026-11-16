SELECT s.item_name,s.size,SUM(s.quantity) AS qty
FROM w11_demo.sales s
JOIN w11_demo.item_dim d USING(item_name)
WHERE d.category='여성복'
GROUP BY s.item_name,s.size
ORDER BY s.item_name,s.size;
