SELECT item_name, SUM(quantity) AS qty
FROM w11_demo.sales
WHERE size='L'
GROUP BY item_name
ORDER BY item_name;
