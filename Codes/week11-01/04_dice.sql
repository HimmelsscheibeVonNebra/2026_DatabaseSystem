SELECT item_name, color, size, quantity
FROM w11_demo.sales
WHERE size='L' AND color='흰색'
  AND item_name IN ('셔츠','바지')
ORDER BY item_name;
