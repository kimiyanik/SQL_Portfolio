-- 1. What is the total amount each customer spent at the restaurant?

SELECT
  	customer_id,
    sum(price) as totalSpend
FROM dannys_diner.sales
JOIN dannys_diner.menu
on dannys_diner.sales.product_id = dannys_diner.menu.product_id
group by customer_id
ORDER BY totalSpend DESC


-- 2. How many days has each customer visited the restaurant?

SELECT 
	customer_id,
    COUNT(DISTINCT order_date)
FROM dannys_diner.sales
GROUP BY customer_id
ORDER BY 2 DESC


-- 3. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT
	product_name,
	COUNT(dannys_diner.sales.product_id)
FROM dannys_diner.sales
JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id 
GROUP BY product_name
ORDER BY 2 DESC
LIMIT 1

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
product_name,
COUNT(customer_id)

FROM dannys_diner.sales
JOIN dannys_diner.menu ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
  
GROUP BY product_name
ORDER BY 2 DESC
LIMIT 1



-- 5. Which item was the most popular food for each customer?


WITH RankedSales AS (
  SELECT
    customer_id,
    product_name,
    COUNT(dannys_diner.sales.product_id) as countP,
    RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(dannys_diner.sales.product_id) DESC) as popularity_rank
  FROM dannys_diner.sales
  JOIN dannys_diner.menu ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
  GROUP BY customer_id, product_name
)

SELECT customer_id, product_name
FROM RankedSales
WHERE popularity_rank = 1;



-- 6. Which item was purchased first by the customer after they became a member?


WITH drank AS(
SELECT 
dannys_diner.sales.customer_id,
product_name,
order_date,
RANK() OVER(PARTITION BY dannys_diner.sales.customer_id ORDER BY order_date ASC)


FROM dannys_diner.sales
LEFT JOIN dannys_diner.members
ON dannys_diner.sales.customer_id = dannys_diner.members.customer_id
JOIN dannys_diner.menu 
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id

where order_date >= join_date
)

SELECT customer_id,
product_name
FROM drank
WHERE rank = 1


-- 7. Which item was purchased just before the customer became a member?
WITH ranked AS (
  
SELECT
dannys_diner.sales.customer_id,
product_id,
RANK() OVER(PARTITION BY sales.customer_id ORDER BY order_date DESC)
FROM dannys_diner.sales
LEFT JOIN dannys_diner.members
ON dannys_diner.sales.customer_id = dannys_diner.members.customer_id

WHERE order_date < join_date
GROUP BY sales.customer_id,product_id,order_date

)

SELECT 
customer_id,
product_name
FROM ranked 
JOIN dannys_diner.menu
ON ranked.product_id = menu.product_id
WHERE rank = 1



-- 8. What is the total items and amount spent for each member before they became a member?

  
SELECT
sales.customer_id,
COUNT (sales.product_id) AS total_orders,
SUM(price) AS total_spent
  
FROM dannys_diner.sales
LEFT JOIN dannys_diner.members
ON dannys_diner.sales.customer_id = dannys_diner.members.customer_id
JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id

WHERE order_date < join_date
GROUP BY sales.customer_id
ORDER BY customer_id


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH point AS (
SELECT
product_id,
CASE 
WHEN product_id = 1 THEN price*10*2
ELSE price*10
END AS points

FROM dannys_diner.menu

GROUP BY product_id,price
)

SELECT 
customer_id,
SUM(points) AS total_points

FROM dannys_diner.sales
JOIN point
ON dannys_diner.sales.product_id = point.product_id

GROUP BY customer_id
ORDER BY customer_id


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

WITH point AS(
SELECT
sales.customer_id,
sales.product_id,

CASE 
WHEN sales.product_id = 1 OR order_date BETWEEN join_date AND join_date+7 THEN price*10*2
ELSE price*10
END AS points

FROM dannys_diner.sales
LEFT JOIN dannys_diner.members
ON dannys_diner.sales.customer_id = dannys_diner.members.customer_id
LEFT JOIN dannys_diner.menu
ON dannys_diner.sales.product_id = dannys_diner.menu.product_id
WHERE order_date < '2021-02-01'
GROUP BY sales.customer_id,sales.product_id,price, order_date,join_date
ORDER BY customer_id
  
)

SELECT 
customer_id,
SUM(points) AS total_points
FROM point
WHERE customer_id IN ('A','B')
GROUP BY customer_id
