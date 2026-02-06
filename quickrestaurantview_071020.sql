USE quickrestaurant

CREATE VIEW vw_total_orders AS
SELECT count(order_id) AS Total_Orders
FROM fact_orders

CREATE VIEW vw_total_orders_by_city AS
SELECT d.city, count(f.order_id) AS Total_Orders
FROM fact_orders f
JOIN dim_restaurant d
ON f.restaurant_id=d.restaurant_id
GROUP BY CITY

CREATE VIEW vw_total_orders_by_restaurant AS
SELECT d.restaurant_name, count(f.order_id) AS Total_Orders
FROM fact_orders f
JOIN dim_restaurant d
ON f.restaurant_id=d.restaurant_id
GROUP BY d.restaurant_name

CREATE VIEW monthly_active_cuatomer AS
SELECT FORMAT(order_timestamp, 'MM') AS month, 
COUNT(DISTINCT customer_id) AS active_customer 
FROM fact_orders
GROUP  BY FORMAT(order_timestamp, 'MM')

CREATE VIEW vw_total_orders_y_month AS
SELECT FORMAT(order_timestamp, 'MM') AS month, count(order_id) AS Total_Orders
FROM fact_orders
GROUP BY FORMAT(order_timestamp, 'MM') 

CREATE VIEW vw_total_revenue_month AS
SELECT FORMAT(order_timestamp, 'MM') AS month, SUM(subtotal_amount) AS Total_Orders
FROM fact_orders
GROUP BY FORMAT(order_timestamp, 'MM') 

CREATE VIEW Total_Revenue AS 
SELECT SUM(subtotal_amount) AS Total_Revenue
FROM fact_orders

CREATE VIEW vw_total_revenue_by_restaurant AS
SELECT d.restaurant_name, SUM(f.subtotal_amount) AS Total_Orders
FROM fact_orders f
JOIN dim_restaurant d
ON f.restaurant_id=d.restaurant_id
GROUP BY d.restaurant_name

CREATE VIEW vw_total_revenue_city AS
SELECT d.city, SUM(f.subtotal_amount) AS Total_Orders
FROM fact_orders f
JOIN dim_restaurant d
ON f.restaurant_id=d.restaurant_id
GROUP BY CITY

SELECT *
FROM total_revenue

CREATE VIEW Active_Customers AS 
SELECT COUNT(DISTINCT customer_id) AS Active_Customer
FROM fact_orders

SELECT *
FROM Active_Customers

CREATE VIEW Cancellation_rate AS 
SELECT COUNT(CASE WHEN is_cancelled='Y' THEN 1 END)*1.0/COUNT(order_id) 
AS cancellaration_rate
FROM fact_orders

CREATE VIEW Cancellation_rate_trend AS 
SELECT FORMAT(order_timestamp, 'MM') AS month, COUNT(order_id) AS Total_Orders,
COUNT(CASE WHEN is_cancelled='Y' THEN 1 END)*1.0/COUNT(order_id) 
AS cancellaration_rate
FROM fact_orders
GROUP BY FORMAT(order_timestamp, 'MM')

CREATE VIEW Avg_Delivery_Delay AS
SELECT AVG(DATEDIFF(MINUTE,expected_delivery_time_mins,
actual_delivery_time_mins))
AS Avg_Delivery_Delay
FROM fact_delivery_performance
WHERE actual_delivery_time_mins>expected_delivery_time_mins

CREATE VIEW Avg_Delivery_Delay_trend AS
SELECT FORMAT(f.order_timestamp, 'MM') AS month, 
AVG(DATEDIFF(MINUTE,p.expected_delivery_time_mins,
p.actual_delivery_time_mins))
AS Avg_Delivery_Delay
FROM fact_delivery_performance p
JOIN fact_orders f
ON p.order_id=f.order_id
WHERE p.actual_delivery_time_mins>p.expected_delivery_time_mins
GROUP BY FORMAT(f.order_timestamp, 'MM')

CREATE VIEW SLA_compliance AS 
SELECT COUNT(CASE WHEN actual_delivery_time_mins<=expected_delivery_time_mins THEN 1 END)*100
/COUNT(order_id) AS SLA_compliance
FROM fact_delivery_performance

CREATE VIEW SLA_compliance_trend AS 
SELECT FORMAT(f.order_timestamp,'MM') AS Month, 
COUNT(CASE WHEN actual_delivery_time_mins<=expected_delivery_time_mins THEN 1 END)*100
/COUNT(p.order_id) AS SLA_compliance
FROM fact_delivery_performance p
JOIN fact_orders f
ON p.order_id=f.order_id
GROUP BY FORMAT(f.order_timestamp,'MM')

CREATE VIEW Cancellation_rate_by_city AS 
SELECT d.city, COUNT(CASE WHEN f.is_cancelled='Y' THEN 1 END)*1.0/COUNT(f.order_id) 
AS cancellaration_rate
FROM fact_orders f
JOIN dim_restaurant d
ON f.restaurant_id=d.restaurant_id
GROUP BY d.city

CREATE VIEW trend_orders AS
SELECT month, total_orders, total_orders-LAG(total_orders)
OVER(ORDER BY month) AS mom_change
FROM(SELECT FORMAT(order_timestamp,'MMMM') AS month, COUNT(order_id) AS Total_Orders
FROM fact_orders 
GROUP BY  FORMAT(order_timestamp,'MMMM'
)) t

CREATE VIEW high_value_customers AS 
SELECT *
FROM(SELECT d.customer_id, SUM(f.subtotal_amount) AS total_revenue, 
NTILE(20) OVER(ORDER BY SUM(f.subtotal_amount)DESC) AS Revenue_Bucket
FROM fact_orders f
JOIN dim_customer d
ON f.customer_id =d.customer_id GROUP BY d.customer_id) t
WHERE Revenue_Bucket=1

CREATE VIEW churned_customers AS
SELECT FORMAT(order_timestamp,'MM') AS month, 
COUNT(DISTINCT ORDER_ID) AS churned_CUSTOMERS
FROM fact_orders
WHERE Loyalty_Segmentation='churned'
GROUP BY  FORMAT(order_timestamp,'MM')

CREATE VIEW Total_Revenue_By_Segmentation AS
SELECT loyalty_segmentation, 
SUM(subtotal_amount) AS Total_Revenue
FROM fact_orders
GROUP BY loyalty_segmentation

CREATE VIEW Avg_time_delivery_40mi(clean) AS
SELECT AVG(actual_delivery_time_mins)
AS Avg_Delivery_time
FROM fact_delivery_performance
WHERE expected_delivery_time_mins=40

CREATE VIEW Avg_time_delivery AS
SELECT AVG(actual_delivery_time_mins)
AS Avg_Delivery_time
FROM fact_delivery_performance


CREATE VIEW Total_Orders_By_Segmentation AS
SELECT loyalty_segmentation, 
count(order_id) AS Total_Revenue
FROM fact_orders
GROUP BY loyalty_segmentation