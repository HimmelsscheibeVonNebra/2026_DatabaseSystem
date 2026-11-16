SELECT item_name, color, SUM(quantity) AS qty,
 GROUPING(item_name,color) AS g
FROM w11_demo.sales
GROUP BY CUBE(item_name,color)
ORDER BY g DESC,item_name,color;
