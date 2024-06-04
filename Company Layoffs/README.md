This is a project including data cleaning and exploratory data analysis on a database about company layoffs worldwide.I've done this project using Mysql. 

Data Cleaning steps:
- Created a duplicate of table
- Find and remove duplicate rows
- Standarizing the data: Remove extra spaces from company names - Standarize the industry names - Standarize the country names - Standarize the date values and convert them from string to date format
- Handling null values: Some rows have missing industry name. I used the available industry name in other rows to fill in the missing values by joining the table to itself.
- Deleting the unnecessary data: I deleted the rows with null values in both total_laid_off and percentage_laid_off fields as they can't be usefull in the EDA step.

Questions answered in the EDA step:
- What are the maximum and minimum values of total layoffs and percentage?
- Which companies have 100% layoff?
- Which industry had the most layoffs?
- Which company had the most layoffs?
- Calculate running total of laid offs per company
- Calculate running total of laid offs per month
- How many employees are laid off per year by each company?
