<h1 align="center">Case Study #1 - Danny's Diner </h1>

<p align="center">
  <strong>Danny’s Diner is in need assistance to help the restaurant stay afloat - the restaurant has captured some very basic data from their few months of operation but have no idea how to use their data to help them run the business. In this project I helped them with several questions. I created this project using PostgreSQL. </strong>
</p>

## Projects Details

<p align="center">
The dataset has 3 tables called 'sales', 'members', and 'menu', related to each other on 'product_id' and 'customer_id' columns. 
    Table 1: sales
The sales table captures all customer_id level purchases with an corresponding order_date and product_id information for when and what menu items were ordered.
Table 2: menu
The menu table maps the product_id to the actual product_name and price of each menu item.
Table 3: members
The final members table captures the join_date when a customer_id joined the beta version of the Danny’s Diner loyalty program.
</p>



## Questions Answered

<p align="center">
  <strong>Questions answered in this project:</strong>
</p>

- What is the total amount each customer spent at the restaurant?
- How many days has each customer visited the restaurant?
- What was the first item from the menu purchased by each customer?
- What is the most purchased item on the menu and how many times was it purchased by all customers?
- Which item was the most popular for each customer?
- Which item was purchased first by the customer after they became a member?
- Which item was purchased just before the customer became a member?
- What is the total items and amount spent for each member before they became a member?
- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
