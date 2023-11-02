--What is the total profit by country?
SELECT     
  Country,
  SUM(Profit) AS TotalProfit
FROM [tt].dbo.[Sales]
GROUP BY  Country
ORDER BY 2 DESC

-- What is the total revenue by country?

SELECT 
     Country,
     SUM(Revenue) AS TotalRevenue
FROM [tt].dbo.[Sales]
GROUP BY  Country
ORDER BY 2 DESC


--What is the total revenue by country and product category?
SELECT 
  Country,
	Product_Category,
  SUM(Revenue) AS TotalRevenue
FROM [tt].dbo.[Sales]
GROUP BY  Country,Product_Category
ORDER BY 1,2

  --What is the total profit by country and product category?

SELECT  
  Country,
	Product_Category,
  SUM(Profit) AS TotalProfit
FROM [tt].dbo.[Sales]
GROUP BY  Country,Product_Category
ORDER BY 1,2


--What is the global revenue performance by year?
SELECT   
   Year,
   SUM(Revenue) AS TotalRevenue
FROM [tt].dbo.[Sales]
GROUP BY  Year
ORDER BY 1 ASC


-- What is the global profit performance by year?
SELECT 
  Year,
  SUM(Profit) AS TotalRevenue
FROM [tt].dbo.[Sales]
GROUP BY  Year
ORDER BY 1 ASC



--What is the revenue according to customer age group?

SELECT   
  Age_Group,
  SUM(Revenue) AS TotalRevenue
FROM [tt].dbo.[Sales]
GROUP BY  Age_Group
ORDER BY 1 ASC

--What is the profit according to customer age group?
SELECT   
    Age_Group,
    SUM(Profit) AS TotalProfit
FROM [tt].dbo.[Sales]
GROUP BY  Age_Group
ORDER BY 1 ASC

  --What is the total order quantity by customer age group?
SELECT   
     Age_Group,
     SUM(Order_Quantity) AS TotalOrders
FROM [tt].dbo.[Sales]
GROUP BY  Age_Group
ORDER BY 1 ASC

--What age groups are the biggest spenders, by country?

SELECT   
	Country,
  Age_Group,
  SUM(Revenue) AS TotalRevenue
FROM [tt].dbo.[Sales]
GROUP BY  Country,Age_Group
ORDER BY 1,2 ASC


  -- What gender is the biggest spender, by country?
SELECT   
	Country,
  Customer_Gender,
  SUM(Revenue) AS TotalRevenue
FROM [tt].dbo.[Sales]
GROUP BY  Country,Customer_Gender
ORDER BY 1,2 ASC

--How much revenue were made in Canada or France?

SELECT   
     SUM(Revenue) AS TotalSales
FROM [tt].dbo.[Sales]
WHERE Country IN ('France','Canada')
  

--How many Bike Racks orders were made from Canada?
SELECT   
     Count(*) AS totalOrders
FROM [tt].dbo.[Sales]
WHERE Country = 'Canada' AND Sub_Category = 'Bike Racks'

  -- How many orders were made in Each State of France?

SELECT   
	State,
  Count(*) AS totalOrders
FROM [tt].dbo.[Sales]
WHERE Country = 'France' 
GROUP BY State
ORDER BY 1 


  --How many sales were made per category?

SELECT   
	Sub_Category,
  Count(*) AS totalOrders
FROM [tt].dbo.[Sales]
GROUP BY Sub_Category
ORDER BY 1 


  --Which gender has the most amount of sales?
SELECT   
	Customer_Gender,
Count(*) AS totalOrders
FROM [tt].dbo.[Sales]
GROUP BY Customer_Gender
ORDER BY 2 DESC

--How many sales with more than 500 in Revenue were made by men?

SELECT   
	Customer_Gender,
  Count(*) AS totalOrders
FROM [tt].dbo.[Sales]
GROUP BY Customer_Gender
ORDER BY 2 DESC


--How many sales with more than 500 in Revenue were made by men?
SELECT   
    COUNT(*) AS orders
FROM [tt].dbo.[Sales]
WHERE Customer_Gender = 'M' AND Revenue >= 500
 

 -- what are the top-5 sales with the highest revenue
SELECT   
	TOP 5 *
FROM [tt].dbo.[Sales]
ORDER BY Revenue DESC
  
-- How much is the Revenue of the sale with the highest revenue
SELECT   
	TOP 1 
	Revenue
FROM [tt].dbo.[Sales]
ORDER BY Revenue DESC

--What is the mean Order_Quantity of orders with less than 10K in revenue?

SELECT   
     AVG(Order_Quantity) AS OrderMean
FROM [tt].dbo.[Sales]
WHERE Revenue < 10000


  --How many orders were made in May of 2016?
SELECT   
     COUNT(*) AS totalOrders
FROM [tt].dbo.[Sales]
WHERE Year = 2016 AND Month = 'May'


  --How many orders were made in May,June,July of 2016?
  SELECT   
     COUNT(*) AS totalOrders
  FROM [tt].dbo.[Sales]
  WHERE Year = 2016 AND Month IN('May','June','July')


--What is the mean revenue of the Adults (35-64) sales group

SELECT   
     AVG(Revenue) AS RevenueMean
FROM [tt].dbo.[Sales]
WHERE Age_Group = 'Adults (35-64)'


--Get the mean revenue of the sales group Adults (35-64) in United States
SELECT   
     AVG(Revenue) AS RevenueMean
FROM [tt].dbo.[Sales]
WHERE Age_Group = 'Adults (35-64)' AND Country = 'United States'
