-- Creating the temporary table for the next steps
CREATE TEMP TABLE customer_orders_temp AS
SELECT 
  order_id, 
  customer_id, 
  pizza_id, 
  CASE
	  WHEN exclusions IS null OR exclusions LIKE 'null' THEN ' '
	  ELSE exclusions
	  END AS exclusions,
  CASE
	  WHEN extras IS NULL or extras LIKE 'null' THEN ' '
	  ELSE extras
	  END AS extras,
	order_time
FROM pizza_runner.customer_orders;

SELECT *
FROM customer_orders_temp;

CREATE TEMP TABLE runner_orders_temp AS
SELECT 
  order_id, 
  runner_id,  
  CASE
	  WHEN pickup_time LIKE 'null' THEN ' '
	  ELSE pickup_time
	  END AS pickup_time,
  CASE
	  WHEN distance LIKE 'null' THEN ' '
	  WHEN distance LIKE '%km' THEN TRIM('km' from distance)
	  ELSE distance 
    END AS distance,
  CASE
	  WHEN duration LIKE 'null' THEN ' '
	  WHEN duration LIKE '%mins' THEN TRIM('mins' from duration)
	  WHEN duration LIKE '%minute' THEN TRIM('minute' from duration)
	  WHEN duration LIKE '%minutes' THEN TRIM('minutes' from duration)
	  ELSE duration
	  END AS duration,
  CASE
	  WHEN cancellation IS NULL or cancellation LIKE 'null' THEN ' '
	  ELSE cancellation
	  END AS cancellation
FROM pizza_runner.runner_orders;

SELECT *
FROM runner_orders_temp;


-- Pizza Metrics
-- How many pizzas were ordered?

SELECT
COUNT(order_id) AS total_piza
FROM customer_orders_temp;

-- How many unique customer orders were made?
SELECT
COUNT(DISTINCT order_id) AS total_piza
FROM customer_orders_temp;

-- How many successful orders were delivered by each runner?
SELECT 
runner_id,
COUNT(order_id)
FROM runner_orders_temp
WHERE cancellation= ' ' OR cancellation= ''
GROUP BY runner_id;

--How many of each type of pizza was delivered?
SELECT 
pizza_name,
COUNT(customer_orders_temp.order_id) AS pitzaCount

FROM customer_orders_temp
LEFT JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
JOIN pizza_runner.pizza_names
ON customer_orders_temp.pizza_id = pizza_names.pizza_id
WHERE runner_orders_temp.distance != ' '
GROUP BY pizza_name
ORDER BY pizza_name;


--How many Vegetarian and Meatlovers were ordered by each customer?
SELECT 
customer_id,
pizza_name,
COUNT(order_id) AS orders
FROM customer_orders_temp
JOIN pizza_runner.pizza_names
ON customer_orders_temp.pizza_id = pizza_names.pizza_id
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name

--What was the maximum number of pizzas delivered in a single order?
SELECT 
MAX(piza_per_order)
FROM
(SELECT 
customer_orders_temp.order_id,
COUNT(pizza_id) AS piza_per_order
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE distance != ' '
GROUP BY customer_orders_temp.order_id
ORDER BY piza_per_order DESC) AS d


--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
customer_orders_temp.customer_id,
SUM(CASE WHEN exclusions <> '' OR extras <> '' THEN 1 ELSE 0 END) AS at_least_1_change,
SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS no_change

FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE distance != ' '
GROUP BY customer_id
ORDER BY customer_id


--How many pizzas were delivered that had both exclusions and extras?

SELECT 
SUM(CASE WHEN exclusions <> '' AND exclusions <> ' ' AND extras <> '' AND extras <> ' ' THEN 1 ELSE 0 END) AS both_changes
FROM customer_orders_temp
JOIN runner_orders_temp
ON customer_orders_temp.order_id = runner_orders_temp.order_id
WHERE distance != ' '


--What was the total volume of pizzas ordered for each hour of the day?
SELECT 
EXTRACT(HOUR FROM order_time) AS order_hour,
COUNT(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY EXTRACT(HOUR FROM order_time)
ORDER BY order_hour


--What was the volume of orders for each day of the week?

SELECT 
EXTRACT(DAYOFWEEK FROM order_time) AS day_of_week,
COUNT(pizza_id) AS pizza_count
FROM customer_orders_temp
GROUP BY EXTRACT(DAYOFWEEK FROM order_time)
ORDER BY day_of_week


--B. Runner and Customer Experience
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT
EXTRACT(WEEK FROM registration_date) AS week,
COUNT(runner_id)

FROM pizza_runner.runners
GROUP BY EXTRACT(WEEK FROM registration_date);

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

SELECT 
AVG(DATEDIFF(MINUTE, c.order_time, r.pickup_time)) AS avg_pickup
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id



--Is there any relationship between the number of pizzas and how long the order takes to prepare?

SELECT 
c.order_id,
COUNT(pizza_id) AS pizza_count,
DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time
FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
WHERE distance != ' '
GROUP BY c.order_id
ORDER BY prep_time DESC

--What was the average distance travelled for each customer?

SELECT 
c.customer_id,
AVG(CASE WHEN distance <> ' ' THEN distance END) AS avg_distance

FROM customer_orders_temp AS c
JOIN runner_orders_temp AS r
ON c.order_id = r.order_id
GROUP BY c.customer_id




--What was the difference between the longest and shortest delivery times for all orders?
WITH mm AS (
SELECT 
MAX(duration::numeric) AS maxd,
MIN(duration::numeric) AS mind
FROM runner_orders_temp
WHERE duration!= ' '
)
SELECT 
maxd - mind AS diff
FROM mm;

--What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
runner_id,
order_id,
COUNT(pizza_id) AS pizzaCount,
ROUND(AVG(distance::numeric / (duration::numeric / 60) ),2) AS speed
FROM 
runner_orders_temp
JOIN customer_orders_temp
USING(order_id)
WHERE duration!= ' '
GROUP BY runner_id, order_id
ORDER BY runner_id, order_id;

-- I converted the mins to hours to calculate the speed in km/h and also calculated the count of pizzas to find out the trend. 


--What is the successful delivery percentage for each runner?
SELECT 
runner_id,
ROUND(AVG(
  CASE WHEN duration = ' ' THEN 0
  WHEN duration != ' ' THEN 1
  END) , 2)  AS success_rate
FROM 
runner_orders_temp
GROUP BY runner_id;


--Ingredient Optimisation
--What are the standard ingredients for each pizza?

WITH toppings_cte AS (
SELECT
  pizza_id,
  REGEXP_SPLIT_TO_TABLE(toppings, '[,\s]+')::INTEGER AS topping_id
FROM pizza_runner.pizza_recipes)

SELECT 
pizza_name,
STRING_AGG(topping_name, ',') AS ingredients 
FROM toppings_cte
JOIN pizza_runner.pizza_toppings
USING(topping_id)
JOIN pizza_runner.pizza_names
USING(pizza_id)
GROUP BY pizza_name;


--What was the most commonly added extra?
WITH exs AS(
SELECT 
order_id,
REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
FROM 
customer_orders_temp
WHERE extras !=' ' AND extras !=''
)


SELECT
topping_name,
COUNT(*) AS count_extras
FROM exs
JOIN pizza_runner.pizza_toppings
USING(topping_id)
GROUP BY topping_name
ORDER BY count_extras DESC
LIMIT 1

--What was the most common exclusion?
WITH excl AS(
SELECT 
order_id,
REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
FROM 
customer_orders_temp
WHERE exclusions !=' ' AND exclusions !=''
)
SELECT
topping_name,
COUNT(*) AS count_exclusions
FROM excl
JOIN pizza_runner.pizza_toppings
USING(topping_id)
GROUP BY topping_name
ORDER BY count_exclusions DESC
LIMIT 1 


/*Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers*/
WITH exs AS(
SELECT 
order_id,
topping_name AS extra_name
FROM(SELECT 
order_id,
REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+')::INTEGER AS topping_id
FROM 
customer_orders_temp
WHERE extras !=' ' AND extras !=''
) AS t1
JOIN pizza_runner.pizza_toppings
USING(topping_id)
GROUP BY order_id
),
excl AS(
SELECT 
order_id,
topping_name AS exclusion_name
FROM(
SELECT 
order_id,
REGEXP_SPLIT_TO_TABLE(exclusions, '[,\s]+')::INTEGER AS topping_id
FROM 
customer_orders_temp
WHERE exclusions !=' ' AND exclusions !=''

) AS t2
JOIN pizza_runner.pizza_toppings
USING(topping_id)
GROUP BY order_id
 )
 
SELECT 
order_id,
exclusion_name,
extra_name

FROM 
exs 
FULL JOIN excl
USING(order_id)
ORDER BY order_id


--D. Pricing and Ratings
--If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

SELECT 
SUM(
  CASE WHEN pizza_id = 1 THEN 12
  WHEN pizza_id = 2 THEN 10
  END) AS total_revenue

FROM customer_orders_temp
JOIN runner_orders_temp 
USING(order_id)
WHERE distance !=' ' AND distance !=''

--What if there was an additional $1 charge for any pizza extras?
WITH ext AS(
SELECT 
order_id,
pizza_id,
REGEXP_SPLIT_TO_TABLE(extras, '[,\s]+') AS extra_list
FROM customer_orders_temp
),
alls AS(
SELECT 
CASE WHEN pizza_id = 1 THEN 12
WHEN pizza_id = 2 THEN 10
END AS revenue
FROM customer_orders_temp
JOIN runner_orders_temp 
USING(order_id)
WHERE distance !=' ' AND distance !=''

UNION ALL
SELECT
SUM(CASE WHEN extra_list != '' THEN 1 
  	ELSE 0 END ) AS revenue
FROM ext
)

SELECT
SUM(revenue) AS total_revenue
FROM alls;

--The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

CREATE TABLE customer_ratings(
  "order_id" INT,
  "customer_rating" INT);
INSERT INTO customer_ratings
("order_id","customer_rating")
VALUES
 ('1', '5'),
  ('2', '4'),
  ('3', '3'),
  ('4', '2'),
  ('5', '3'),
  ('7', '2'),
  ('8', '2'),
  ('10', '1');
  
SELECT *
FROM customer_ratings
