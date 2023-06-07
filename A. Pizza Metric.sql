--1. How many pizzas were ordered?

Answer:
	no_of_pizza_ordered
	14

SELECT COUNT(order_id) AS no_of_pizza_ordered
FROM pizza_runner..customer_orders


--2. How many unique customer orders were made?

Answer:
	customer_id		unique_orders
	101				3
	102				3
	103				4
	104				3
	105				1

SELECT 
	customer_id,
	COUNT(customer_id) AS unique_orders
FROM pizza_runner..customer_orders
GROUP BY customer_id

--3. How many successful orders were delivered by each runner?

Answer:
	runner_id	successful_orders
			1	4
			2	3
			3	1

SELECT 
	runner_id, 
	COUNT(*) AS successful_orders
FROM pizza_runner..runner_orders
WHERE cancellation = ''
GROUP BY runner_id


--4. How many of each type of pizza was delivered?

Answer: 
	Type_of_Pizza	No_of_deliverd_pizza
		Meatlovers	9
		Vegetarian	3

SELECT 
	CAST(pizza_name AS varchar(100)) AS Type_of_Pizza, 
	COUNT(*) AS No_of_deliverd_pizza
FROM pizza_runner..pizza_names
JOIN pizza_runner..customer_orders 
ON pizza_names.pizza_id = customer_orders.pizza_id
JOIN pizza_runner..runner_orders
ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation = ''
GROUP BY CAST(pizza_name AS varchar(100))


--5. How many Vegetarian and Meatlovers were ordered by each customer?

Answer:
	customer_id	pizza_type	no_of_orders
		101		Meatlovers			2
		101		Vegetarian			1
		102		Meatlovers			2
		102		Vegetarian			1
		103		Meatlovers			3
		103		Vegetarian			1
		104		Meatlovers			3
		105		Vegetarian			1

SELECT 
	customer_id,
	CAST(pizza_name AS varchar(100)) AS pizza_type,
	COUNT(*) AS no_of_orders
FROM pizza_runner..pizza_names
JOIN pizza_runner..customer_orders 
ON pizza_names.pizza_id = customer_orders.pizza_id
GROUP BY customer_id , CAST(pizza_name AS varchar(100)) 
ORDER BY customer_id


--6. What was the maximum number of pizzas delivered in a single order?

Answer:
	max_no_of_pizzas_in_single_order
	3

WITH CTE AS (
SELECT 
	customer_orders.order_id,
	pickup_time,
	ROW_NUMBER() OVER (PARTITION BY customer_orders.order_id ORDER BY customer_orders.order_id) AS rank_num
FROM pizza_runner..customer_orders 
JOIN pizza_runner..runner_orders
ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation = ''
)
SELECT
	MAX(rank_num) AS max_no_of_pizzas_in_single_order
FROM CTE

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

Answer:
customer_id	had_change	had_no_change
	101				0			2	
	102				0			3
	103				3			0
	104				2			1
	105				1			0

SELECT 
	customer_orders.customer_id,
	SUM(CASE
		WHEN exclusions <> '' OR extras <> '' THEN 1
		ELSE 0
		END) AS had_change,
	SUM(CASE
		WHEN exclusions = '' AND extras = '' THEN 1
		ELSE 0
		END) AS had_no_change
FROM pizza_runner..customer_orders 
JOIN pizza_runner..runner_orders
ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation = ''
GROUP BY customer_orders.customer_id


--8. How many pizzas were delivered that had both exclusions and extras?

Answer: 
had_both_change
1

SELECT 
	SUM(CASE
		WHEN exclusions <> '' AND extras <> '' THEN 1
		ELSE 0
		END) AS had_both_change
FROM pizza_runner..customer_orders 
JOIN pizza_runner..runner_orders
ON customer_orders.order_id = runner_orders.order_id
WHERE runner_orders.cancellation = ''


--9. What was the total volume of pizzas ordered for each hour of the day?

Answer:
hours_of_the_day total_volume
			13		3
			18		3
			19		1
			21		2
			23		3	

WITH CTE AS (
	SELECT CASE DATEPART(dayofyear, order_time) AS day_of_the_week
	FROM pizza_runner..customer_orders 
	JOIN pizza_runner..runner_orders
	ON customer_orders.order_id = runner_orders.order_id
	WHERE runner_orders.cancellation = ''
)
SELECT day_of_the_week, COUNT(*) total_volume
FROM CTE
GROUP BY day_of_the_week


--10. What was the volume of orders for each day of the week?

Answer:
day_of_week	total_volume
Saturday	5
Thursday	3
Wednesday	4

WITH CTE AS (
	SELECT CASE DATEPART(dw, order_time)
		WHEN 1 THEN 'Sunday'
		WHEN 2 THEN 'Monday'
		WHEN 3 THEN 'Tuesday'
		WHEN 4 THEN 'Wednesday'
		WHEN 5 THEN 'Thursday'
		WHEN 6 THEN 'Friday'
		ELSE 'Saturday' 
		END AS day_of_week, 
	order_time
	FROM pizza_runner..customer_orders 
	JOIN pizza_runner..runner_orders
	ON customer_orders.order_id = runner_orders.order_id
	WHERE runner_orders.cancellation = ''
)
SELECT day_of_week, COUNT(*) total_volume
FROM CTE
GROUP BY day_of_week
