SELECT item_name,size,SUM(quantity) AS qty,
 GROUPING(item_name,size) AS g
FROM w11_demo.sales
GROUP BY GROUPING SETS ((item_name),(size),())
ORDER BY g,item_name,size;
