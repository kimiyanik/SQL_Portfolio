SELECT
*
FROM layoffs_
LIMIT 10;


-- Create a copy of the table

CREATE TABLE layoffs_s
LIKE layoffs_;


INSERT layoffs_s
SELECT
*
FROM layoffs_;

SELECT
*
FROM layoffs_s;


-- Find and remove duplicates

-- Find the duplicates

WITH row_n AS(
SELECT 
*,
ROW_NUMBER()OVER(partition by company,location,industry,total_laid_off, percentage_laid_off,date,stage,country,funds_raised_millions) AS row_numbers
FROM layoffs_s)

SELECT 
* 
FROM row_n
WHERE row_numbers > 1;


-- Delete the duplicates
-- First I create a table to keep the row numbers as a new column


CREATE TABLE `layoffs_s_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_number` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT
* 
FROM layoffs_s_2;


-- Insert all the data including the row number column in the new table
INSERT layoffs_s_2
SELECT 
*,
ROW_NUMBER()OVER(partition by company,location,industry,total_laid_off, percentage_laid_off,date,stage,country,funds_raised_millions) AS row_numbers
FROM layoffs_s;


SELECT
* 
FROM layoffs_s_2
WHERE `row_number`>1
;

-- Deleting all the duplicate rows from the new table

DELETE 
FROM layoffs_s_2
WHERE `row_number`>1;

-- Now I can delete the column with row numbers as I don't need it anymore

ALTER TABLE layoffs_s_2
DROP COLUMN `row_number`;


-- Standarizing the data

SELECT
*
FROM layoffs_s_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

-- Remove extra spaces in the company name column

SELECT
company, TRIM(company)
FROM layoffs_s_2;

UPDATE layoffs_s_2
SET company = TRIM(company);

-- Check industry values
SELECT
DISTINCT industry
FROM layoffs_s_2
ORDER BY 1 ASC;

-- We have Crypto, Crypto Currency and CryptoCurrency which are all the same, so we need to standarize them all to Crypto

UPDATE layoffs_s_2
SET industry = 'Crypto'
WHERE industry LIKE '%Crypto%';

-- Standarize Country values

SELECT
DISTINCT country
FROM layoffs_s_2
ORDER BY 1 ASC;

UPDATE layoffs_s_2
SET country = 'United States'
WHERE country LIKE '%United States%';


-- Standirize the dates

SELECT
`date`,
str_to_date(`date`,'%m/%d/%Y')
FROM layoffs_s_2;


UPDATE layoffs_s_2
SET `date` = str_to_date(`date`,'%m/%d/%Y');


ALTER TABLE layoffs_s_2
MODIFY COLUMN `date` DATE;

-- Handling null values
-- Update blank values to nulls

SELECT
*
FROM layoffs_s_2
WHERE industry = '' OR industry IS NULL;

UPDATE layoffs_s_2
SET industry = null
WHERE industry = '';


SELECT
t1.company,
t1.industry,
t2.industry
FROM layoffs_s_2 AS t1
JOIN layoffs_s_2 AS t2
ON t1.company = t2.company
AND t1.location = t2.location
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


UPDATE layoffs_s_2 AS t1
JOIN layoffs_s_2 AS t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;


SELECT
*
FROM layoffs_s_2
WHERE percentage_laid_off IS NULL 
AND total_laid_off IS NULL;

-- Delete the rows with no data about the number of laid off employees
DELETE
FROM layoffs_s_2
WHERE percentage_laid_off IS NULL 
AND total_laid_off IS NULL;
