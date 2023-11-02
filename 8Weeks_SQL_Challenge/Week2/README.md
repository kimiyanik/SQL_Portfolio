<h1 align="center">Case Study #2 - Pizza Runner</h1>

<p align="center">
  <strong>Danny started by recruiting “runners” to deliver fresh pizza from Pizza Runner Headquarters and also maxed out his credit card to pay freelance developers to build a mobile app to accept orders from customers. I used the dataset with 6 tables to answer the questions related to this business. I created this project using PostgreSQL. </strong>
</p>

## Projects Details

<p align="center">
The dataset has 6 tables called 'runners', 'runner_order', 'customer_orders', 'pizza_names', 'pizaa_recepies', and 'pizaa_toppings'.
</p>



## Questions Answered

<p align="center">
  <strong>Questions answered in this project:</strong>
</p>

A. Pizza Metrics

- How many pizzas were ordered?
- How many unique customer orders were made?
- How many successful orders were delivered by each runner?
- How many of each type of pizza was delivered?
- How many Vegetarian and Meatlovers were ordered by each customer?
- What was the maximum number of pizzas delivered in a single order?
- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
- How many pizzas were delivered that had both exclusions and extras?
- What was the total volume of pizzas ordered for each hour of the day?
- What was the volume of orders for each day of the week?

B. Runner and Customer Experience

- How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
- What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
- Is there any relationship between the number of pizzas and how long the order takes to prepare?
- What was the average distance travelled for each customer?
- What was the difference between the longest and shortest delivery times for all orders?
- What was the average speed for each runner for each delivery and do you notice any trend for these values?
- What is the successful delivery percentage for each runner?

C. Ingredient Optimisation

- What are the standard ingredients for each pizza?
- What was the most commonly added extra?
- What was the most common exclusion?
- Generate an order item for each record in the customers_orders table in the format of one of the following:
Meat Lovers
Meat Lovers - Exclude Beef
Meat Lovers - Extra Bacon
Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers


D. Pricing and Ratings

- If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
- What if there was an additional $1 charge for any pizza extras?
- The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
