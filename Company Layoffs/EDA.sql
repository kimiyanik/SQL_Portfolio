-- Exploratory Data Analysis

SELECT
*
FROM layoffs_s_2;

-- Check maximum values of total lay offs and percentage
SELECT
MAX(total_laid_off),
MAX(percentage_laid_off)
FROM layoffs_s_2;

-- Which companies have 100% lay off? 
SELECT
*
FROM layoffs_s_2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

-- Which company had the biggest lay offs?
SELECT
company,
SUM(total_laid_off)
FROM layoffs_s_2
GROUP BY 1
ORDER BY 2 DESC;

-- Which industry had the biggest lay offs?
SELECT
industry,
SUM(total_laid_off)
FROM layoffs_s_2
GROUP BY 1
ORDER BY 2 DESC;

-- Which country had the biggest lay offs?
SELECT
country,
SUM(total_laid_off)
FROM layoffs_s_2
GROUP BY 1
ORDER BY 2 DESC;

-- Which country had the most lay offs?
SELECT
YEAR(`date`),
SUM(total_laid_off)
FROM layoffs_s_2
GROUP BY 1
ORDER BY 2 DESC;

-- Calculate running total of laid offs per company
SELECT
company,
`date`,
industry,
stage,
SUM(total_laid_off) OVER(PARTITION BY company ORDER BY `date` ASC) AS laid_off
FROM layoffs_s_2
GROUP BY company, `date`,industry,stage,total_laid_off
ORDER BY 1 ;

-- Calculate running total of laid offs per month
WITH totals AS(
SELECT
SUBSTRING(`date`,1,7) AS `Month`,
SUM(total_laid_off) AS total_offs
FROM layoffs_s_2
WHERE `date` IS NOT NULL
GROUP BY `Month`
ORDER BY 1 ASC
)
SELECT
`Month`,
SUM(total_offs) OVER(ORDER BY `Month` ASC) AS running_total
FROM totals
ORDER BY 1;

-- How many employees are laid off per year by each company?
WITH a AS(
SELECT
company,
YEAR(`date`) AS y,
SUM(total_laid_off) AS layoffs
FROM layoffs_s_2
GROUP BY 1,2
ORDER BY 3 DESC
)
SELECT
company,
y,
layoffs,
DENSE_RANK()OVER(PARTITION BY y ORDER BY layoffs DESC) AS rank_lay_offs
FROM a
WHERE y IS NOT NULL
GROUP BY 1,2
ORDER BY 4 ASC;

