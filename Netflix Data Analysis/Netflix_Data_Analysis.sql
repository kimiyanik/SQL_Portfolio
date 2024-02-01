
-- Who is the director with most movies in the list?
SELECT
	director,
	COUNT(*) AS movie_count
FROM
	[Netlix].[dbo].[netflix_titles$]
WHERE
	director IS NOT NULL
GROUP BY
	director
ORDER BY 
	COUNT(*) DESC;


--What are the top 5 countries with most visits in the list? 

SELECT TOP 5
	TRIM(value) AS country1,
	COUNT(*)
FROM
	[Netlix].[dbo].[netflix_titles$]
CROSS APPLY 
	STRING_SPLIT(country,',') AS SplitValues
GROUP BY 
	TRIM(value)
ORDER BY  
	COUNT(*) DESC;

--What is the release year of most movies? 
SELECT
	release_year,
	COUNT(*) AS movie_count
FROM
	[Netlix].[dbo].[netflix_titles$]
WHERE 
	release_year IS NOT NULL
	AND type = 'Movie'
GROUP BY 
	release_year
ORDER BY  
	COUNT(*) DESC;

-- What are the top 3 ratings?
SELECT TOP 3
	rating,
	COUNT(*) AS movie_count
FROM 
	[Netlix].[dbo].[netflix_titles$]
WHERE 
	rating IS NOT NULL
GROUP BY 
	rating
ORDER BY 
	COUNT(*) DESC;

-- What are the most popular duration of tv shows in the list?
SELECT TOP 10
	duration,
	COUNT(*) AS movie_count
FROM
	dbo.netflix_titles$ 
WHERE 
	duration IS NOT NULL
	AND type = 'TV Show'
GROUP BY
	duration
ORDER BY 
	COUNT(*) DESC;

-- What percentage of the shows in the list are tv shows?

SELECT
    type,
    COUNT(*) AS total_count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER () AS DECIMAL(10, 2)) AS percentage
FROM
    dbo.netflix_titles$
GROUP BY
    type;


-- How has the number of Netflix titles added per year changed over time?
SELECT
	DATEPART(YEAR,date_added) AS YearAdded,
	COUNT(date_added) AS movieCount

FROM 
	[Netlix].[dbo].[netflix_titles$]
WHERE 
	date_added IS NOT NULL
GROUP BY
	DATEPART(YEAR,date_added)
ORDER BY 
	DATEPART(YEAR,date_added)


-- What are the most common genres for Netflix content - Movies vs TV Shows?

SELECT
	type,
	TRIM(value) AS genre,
	COUNT(*) AS count

FROM 
	[Netlix].[dbo].[netflix_titles$]

CROSS APPLY
	STRING_SPLIT(listed_in, ',') AS separatedVal

WHERE 
	listed_in IS NOT NULL
	AND type IS NOT NULL
GROUP BY
	type,TRIM(value)
ORDER BY 
	type,  COUNT(*) DESC

--What are the Top 3 genres per type?
SELECT
	type,
	genre
FROM (
	SELECT
	type,
	TRIM(value) AS genre,
	COUNT(*) AS count,
	RANK()
	OVER(PARTITION BY type ORDER BY COUNT(*) DESC) AS mrank

FROM 
	[Netlix].[dbo].[netflix_titles$]

CROSS APPLY
	STRING_SPLIT(listed_in, ',') AS separatedVal

WHERE 
	listed_in IS NOT NULL
	AND type IS NOT NULL
GROUP BY
	type,TRIM(value)
) AS t
WHERE mrank <= 3

-- What is the average duration of a Netflix movie versus a TV show?
SELECT
	type,
	CAST(AVG(duration) AS DECIMAL(10, 2)) AS avgDuration
FROM(
	SELECT
	title,
	type,
	CASE
		WHEN type = 'TV Show' THEN 
							CAST(SUBSTRING(duration,1,PATINDEX('% season%', duration)-1) AS DECIMAL)
		WHEN type = 'Movie' THEN 
					    	CAST(SUBSTRING(duration,1,PATINDEX('% min%', duration)-1) AS DECIMAL)

		END AS duration

	FROM [Netlix].[dbo].[netflix_titles$]
	) AS t
GROUP BY 
	type


-- What is the trend in the number of movies versus TV shows added to Netflix over time?

SELECT
	type,
	DATEPART(YEAR, date_added),
	COUNT(*) AS showCount
FROM 
	[Netlix].[dbo].[netflix_titles$]
WHERE
	date_added IS NOT NULL
GROUP BY
	type, DATEPART(YEAR, date_added)
ORDER BY
	type,DATEPART(YEAR, date_added)

-- How many Netflix titles have a title or description that mentions a specific keyword?

SELECT 
	keyword_groups,
	COUNT(*) AS count
FROM (
    SELECT 
        CASE
            WHEN description LIKE '%coming of age%' OR description LIKE '%crime%' OR description LIKE '%family dynamics%'
                THEN 'Theme keywords'
            WHEN description LIKE '%New York City%' OR description LIKE '%outer space%' OR description LIKE '%medieval Europe%'
                THEN 'Setting keywords'
            WHEN description LIKE '%inequality%' OR description LIKE '%climate change%' OR description LIKE '%addiction%'
                THEN 'Social issue keywords'
            ELSE 'other'
        END  AS keyword_groups
    FROM [Netlix].[dbo].[netflix_titles$]
	) AS subquery
GROUP BY 
	keyword_groups;


-- boys vs men vs girls vs women in the title of the movies:
SELECT
	gender_group,
	COUNT(*) AS count
FROM (
	SELECT  
       CASE
        WHEN LOWER(description) LIKE '%girl%' OR LOWER(description) LIKE '%woman%' OR LOWER(title) LIKE '%girl%' OR LOWER(title) LIKE '%woman%' THEN 'girl/woman'
        WHEN LOWER(description) LIKE '%boy%' OR LOWER(description) LIKE '%man%' OR LOWER(title) LIKE '%boy%' OR LOWER(title) LIKE '%man%' THEN 'boy/man'
        ELSE 'other'
           END  AS gender_group
      
	FROM  [Netlix].[dbo].[netflix_titles$]
	)
	AS t
GROUP BY
	gender_group;


-- What are the most popular countries for producing content in a specific genre, and how has this changed over time?
WITH ct AS(
SELECT
	title,
	release_year,
	genre,
	TRIM(value) AS country

FROM (
	SELECT
		title,
		TRIM(value) AS genre,
		country,
		release_year
	
	FROM  
		[Netlix].[dbo].[netflix_titles$]
	CROSS APPLY 
	string_split(listed_in,',') AS separatedValues
	WHERE country IS NOT NULL
	AND listed_in IS NOT NULL
	) AS t

CROSS APPLY 
string_split(country,',') AS separatedValues

),
counts AS(
SELECT
	genre,
	country,
	count(*) AS count

FROM ct
WHERE country IS NOT NULL
GROUP BY
	genre,
	country),
maximum AS(
SELECT
	country,
	genre
FROM counts 
WHERE count = (
SELECT
MAX(count)
FROM counts)
)

SELECT
ct.country,
ct.genre,
release_year,
COUNT(*) AS totalMovie
FROM ct
JOIN maximum
ON ct.country = maximum.country AND ct.genre = maximum.genre
GROUP BY ct.country,
ct.genre,
release_year
ORDER BY release_year






