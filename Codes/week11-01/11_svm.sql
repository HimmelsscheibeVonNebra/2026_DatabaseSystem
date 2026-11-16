-- 설명용 경계 f(x)=0.1*income-5 (income 단위: 천)
SELECT id,income,
 0.1*(income/1000.0)-5 AS margin_score,
 CASE WHEN 0.1*(income/1000.0)-5>=0
      THEN 'B' ELSE 'A' END AS predicted
FROM w11_demo.customer_case ORDER BY id;
