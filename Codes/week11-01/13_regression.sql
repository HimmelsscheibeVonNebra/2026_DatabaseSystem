SELECT ROUND(regr_intercept(y,x)::numeric,2) AS intercept,
 ROUND(regr_slope(y,x)::numeric,2) AS slope,
 ROUND((regr_intercept(y,x)+7*regr_slope(y,x))
       ::numeric,2) AS prediction_x7
FROM w11_demo.ad_sales;
