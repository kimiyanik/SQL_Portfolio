<h1 align="center">Case Study #3 - Foodie-Fi</h1>

<p align="center">
  <strong>Danny finds a few smart friends to launch his new startup Foodie-Fi in 2020 and started selling monthly and annual subscriptions, giving their customers unlimited on-demand access to exclusive food videos from around the world! In this project I helped the business solve several questions. I created this project using PostgreSQL. </strong>
</p>

## Projects Details

<p align="center">
The dataset has 2 tables called 'plans' and 'subscriptions'. 
</p>



## Questions Answered

<p align="center">
  <strong>Questions answered in this project:</strong>
</p>
Data Analysis Questions
- How many customers has Foodie-Fi ever had?
- What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
- What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
- What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
- How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
- What is the number and percentage of customer plans after their initial free trial?
- What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
- How many customers have upgraded to an annual plan in 2020?
- How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
- Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
- How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

Challenge Payment Question
The Foodie-Fi team wants to create a new payments table for the year 2020 that includes amounts paid by each customer in the subscriptions table with the following requirements:

- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
