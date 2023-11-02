
--How many customers has Foodie-Fi ever had?

SELECT
COUNT(DISTINCT customer_id)
FROM foodie_fi.subscriptions

-- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
SELECT 
EXTRACT(MONTH FROM start_date) AS Months,
COUNT(customer_id) AS coount_of_trials
FROM foodie_fi.subscriptions
WHERE plan_id = 0
GROUP BY 1
ORDER BY 1 ASC


-- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name

SELECT 
plan_name,
COUNT(plan_name) AS total_events

FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)
WHERE start_date >= '2021-01-01'
GROUP BY plan_name
ORDER BY 1


--What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
SELECT
COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END) AS customer_count,
ROUND(100 * COUNT(DISTINCT CASE WHEN plan_id = 4 THEN customer_id END)/COUNT(DISTINCT customer_id) ,1) AS churned_per
FROM foodie_fi.subscriptions



--How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH prpl AS (
SELECT 
customer_id,
plan_id,
LAG(plan_id,1) OVER(PARTITION BY customer_id) AS prev_plan
FROM foodie_fi.subscriptions)

SELECT 
COUNT(DISTINCT CASE WHEN plan_id = 4 AND prev_plan = 0 THEN customer_id END) AS count_of_churned_after_trial,  
ROUND(100 * COUNT (CASE WHEN plan_id = 4 AND prev_plan = 0 THEN customer_id END) /COUNT(DISTINCT customer_id) ,1) AS percent_churn
FROM prpl



-- What is the number and percentage of customer plans after their initial free trial?
WITH nextP AS(
SELECT
customer_id,
plan_id,
LEAD(plan_id,1) OVER(PARTITION BY customer_id ORDER BY plan_id) AS next_plan
FROM foodie_fi.subscriptions
)

SELECT 
next_plan,
COUNT(customer_id) AS users,
ROUND(100* COUNT(customer_id) /(SELECT COUNT(DISTINCT customer_id) 
      FROM foodie_fi.subscriptions), 2) AS percentage

FROM nextP
WHERE plan_id = 0
GROUP BY 1



-- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
WITH nextd AS(
SELECT 
customer_id,
plan_id,
start_date,
LEAD(start_date,1) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_date
FROM foodie_fi.subscriptions
  WHERE start_date <= '2020-12-31'
  )
  
SELECT 
plan_id,
COUNT(DISTINCT customer_id) AS customers,
100*COUNT(DISTINCT customer_id) / (SELECT COUNT(DISTINCT customer_id) FROM foodie_fi.subscriptions ) AS percentage
FROM nextd
WHERE next_date IS NULL
GROUP BY 1



--How many customers have upgraded to an annual plan in 2020?
SELECT 
COUNT(customer_id) AS countOfUP
FROM foodie_fi.subscriptions 
WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
AND plan_id = 3



--How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi? 
WITH prev AS(SELECT 
customer_id,
plan_id,
start_date,
LAG(start_date) OVER(PARTITION BY customer_id) AS previous_date
FROM foodie_fi.subscriptions
) 
,begin_dates AS(
SELECT 
customer_id,
plan_id,
start_date AS begininnig
FROM prev
WHERE previous_date IS NULL 
),
ends AS(
SELECT 
customer_id,
plan_id,
start_date AS annual_date
FROM foodie_fi.subscriptions
WHERE plan_id = 3
)

SELECT 
ROUND(AVG(e.annual_date - b.begininnig)) AS average_days_to_annual

FROM ends AS e
LEFT JOIN begin_dates AS b
USING(customer_id)



--Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)

WITH prev AS(SELECT 
customer_id,
plan_id,
start_date,
LAG(start_date) OVER(PARTITION BY customer_id) AS previous_date
FROM foodie_fi.subscriptions
) 
,begin_dates AS(
SELECT 
customer_id,
plan_id,
start_date AS begininnig
FROM prev
WHERE previous_date IS NULL 
),
ends AS(
SELECT 
customer_id,
plan_id,
start_date AS annual_date
FROM foodie_fi.subscriptions
WHERE plan_id = 3
)
,
days_to_convert AS( 
SELECT 
customer_id,
e.annual_date - b.begininnig AS convert_days
FROM ends AS e
LEFT JOIN begin_dates AS b
USING(customer_id)
  )

SELECT 
CASE WHEN convert_days BETWEEN 0 and 30 then'0 to 30'
 when convert_days between 31 and  60 then'31 to 60'
 when convert_days between 61 and 90 then'61 to 90'
 when convert_days between 91 and 120 then'91 to 120'
 when convert_days between 121 and 150 then'121 to 150'
 when convert_days between 150 and 180 then'151 to 180'
 when convert_days > 180 then 'More than 6 months'
 END AS time_period,
 COUNT(*) AS sub_number
 FROM days_to_convert
 GROUP BY 1;



 --How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
WITH pplan AS(
SELECT 
customer_id,
plan_id,
start_date,
LAG(plan_id) OVER(PARTITION BY customer_id) AS pre_plan
FROM foodie_fi.subscriptions
WHERE start_date BETWEEN '2020-01-01' AND '2020-12-31'
  ) 
  
SELECT 
COUNT(customer_id) AS downgrade_count
FROM pplan
WHERE plan_id = 1 AND pre_plan = 2;



--C. Challenge Payment Question

--The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:


CREATE TABLE payments(
  customer_id INT,
  plan_id INT,
  plan_name VARCHAR(13),
  payment_date DATE,
  amount DECIMAL(5,2),
  payment_order INT
  );




   
WITH next_d AS(
SELECT 
customer_id,
plan_id,
plan_name,
start_date,
price,
LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date) AS next_date

FROM foodie_fi.subscriptions
JOIN foodie_fi.plans
USING (plan_id)

WHERE start_date>= '2020-01-01' AND start_date<= '2020-12-31'
  
),

paid AS(
  
SELECT
customer_id,
plan_id,
plan_name,
start_date,
price,
CASE WHEN next_date IS NULL THEN '2020-12-31'
 ELSE next_date
 END AS next_date
FROM next_d
WHERE plan_id IN (1,2,3)
 ),
next_month_pay AS(
SELECT 
customer_id,
plan_id,
plan_name,
start_date,
price,
next_date,
next_date - INTERVAL '1 month' AS next_payment
FROM paid
),
topp AS(
SELECT 
customer_id,
plan_id,
plan_name,
price,
next_date,
next_payment,
start_date AS payment_date

FROM next_month_pay
  
UNION ALL
  
SELECT 
t.customer_id,
t.plan_id,
t.plan_name,
t.price,
t.next_date,
t.next_payment,
t.payment_date + INTERVAL '1 month' AS payment_date

FROM topp AS t
WHERE t.payment_date<t.next_payment
AND  t.plan_id != 3
)

SELECT 
*
from topp;

