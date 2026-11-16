-- 설명용 한 뉴런: z=0.1*x-5, 출력=sigmoid(z)
SELECT id,income,
 ROUND((1.0/(1+EXP(-(0.1*income/1000.0-5))))
       ::numeric,3) AS sigmoid_output
FROM w11_demo.customer_case ORDER BY id;
