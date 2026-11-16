-- 활성 배치=2: offset<=1, 실시간=offset>1
SELECT 'batch' AS path,SUM(b.amount) AS amount
FROM w11_demo.batch_sales b
JOIN w11_demo.serving_head h ON b.batch_id=h.active_batch_id
UNION ALL
SELECT 'speed',SUM(amount) FROM w11_demo.speed_tail
UNION ALL
SELECT 'combined',SUM(amount) FROM w11_demo.sales_current;
