CREATE TABLE CovidStatsStaging (
    Province VARCHAR(100),
    CountryRegion VARCHAR(100),
    Latitude VARCHAR(50),
    Longitude VARCHAR(50),
    Date VARCHAR(50),
    Confirmed VARCHAR(50),
    Deaths VARCHAR(50),
    Recovered VARCHAR(50)
);

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Corona Virus Dataset.csv'
INTO TABLE CovidStatsStaging
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

CREATE TABLE Covid_Stats (
    Province VARCHAR(255),
    CountryRegion VARCHAR(255),
    Latitude DECIMAL(11, 8),
    Longitude DECIMAL(11, 8),
    Date DATE,
    Confirmed INT,
    Deaths INT,
    Recovered INT
);

INSERT INTO Covid_Stats (Province, CountryRegion, Latitude, Longitude, Date, Confirmed, Deaths, Recovered)
SELECT
    Province,
    CountryRegion,
    CONVERT(Latitude, DECIMAL(11, 8)),
    CONVERT(Longitude, DECIMAL(11, 8)),
    CASE 
        WHEN Date LIKE '%/%/%' THEN STR_TO_DATE(Date, '%d/%m/%Y')
        WHEN Date LIKE '%-%-%' THEN STR_TO_DATE(Date, '%d-%m-%Y')
        ELSE NULL
    END AS Date,
    CONVERT(Confirmed, UNSIGNED INTEGER),
    CONVERT(Deaths, UNSIGNED INTEGER),
    CONVERT(Recovered, UNSIGNED INTEGER)
FROM
    CovidStatsStaging;

SELECT * FROM Covid_Stats LIMIT 10;
DROP TABLE CovidStatsStaging;

-- ANALYSIS 
-- Q1. Write a code to check NULL values
SELECT *
FROM Covid_Stats
WHERE 
    Province IS NULL OR
    CountryRegion IS NULL OR
    Latitude IS NULL OR
    Longitude IS NULL OR
    Date IS NULL OR
    Confirmed IS NULL OR
    Deaths IS NULL OR
    Recovered IS NULL;


-- Q2. If NULL values are present, update them with zeros for all columns.
-- There are no null values


-- Q3. check total number of rows
SELECT COUNT(*) AS 'Total Rows'
FROM covid_stats;


-- Q4. Check what is start_date and end_date
SELECT min(Date) AS 'Start Date', max(Date) AS 'End Date'
FROM covid_stats;


-- Q5. Number of month present in dataset
SELECT COUNT(DISTINCT DATE_FORMAT(Date, '%Y-%m')) AS 'Distinct Month'
FROM covid_stats;


-- Q6. Find monthly average for confirmed, deaths, recovered
SELECT DATE_FORMAT(Date, '%M-%Y') AS Month, 
	AVG(Confirmed) AS 'Avg confirmed', 
    AVG(Deaths) AS 'Avg Deaths', 
    AVG(Recovered) AS 'Avg recovered'
FROM  covid_stats
GROUP BY DATE_FORMAT(Date, '%M-%Y')
ORDER BY Month;


-- Q7. Find most frequent value for confirmed, deaths, recovered each month 
SELECT 
    Month,
    (SELECT Confirmed 
     FROM covid_stats AS cd1 
     WHERE cd1.Date LIKE CONCAT(Month, '%') 
     GROUP BY Confirmed 
     ORDER BY COUNT(*) DESC
     LIMIT 1
    ) AS MostFrequentConfirmed,
    (SELECT Deaths 
     FROM covid_stats AS cd2 
     WHERE cd2.Date LIKE CONCAT(Month, '%') 
     GROUP BY Deaths 
     ORDER BY COUNT(*) DESC 
     LIMIT 1
    ) AS MostFrequentDeaths,
    (SELECT Recovered 
     FROM covid_stats AS cd3 
     WHERE cd3.Date LIKE CONCAT(Month, '%') 
     GROUP BY Recovered 
     ORDER BY COUNT(*) DESC 
     LIMIT 1
    ) AS MostFrequentRecovered
FROM 
    (SELECT DISTINCT DATE_FORMAT(`Date`, '%Y-%m') AS Month 
     FROM covid_stats
    ) AS months;

SELECT *
FROM covid_stats;


-- Q8. Find minimum values for confirmed, deaths, recovered per year
SELECT 
	MIN(Confirmed) AS 'Min Confirmed', 
    MIN(Deaths) AS 'Min Deaths', 
    MIN(Recovered) AS 'Min Recovered', 
    DATE_FORMAT(Date, '%Y') AS YEAR
FROM covid_stats
GROUP BY YEAR;



-- Q9. Find maximum values of confirmed, deaths, recovered per year
SELECT 
	MAX(Confirmed) AS 'Max Confirmed', 
    MAX(Deaths) AS 'Max Deaths', 
    MAX(Recovered) AS 'Max Recovered', 
    DATE_FORMAT(Date, '%Y') AS YEAR
FROM covid_stats
GROUP BY YEAR;



-- Q10. The total number of case of confirmed, deaths, recovered each month
SELECT 
	SUM(Confirmed) AS 'Total Confirmed', 
	SUM(Deaths) AS 'Total Deaths', 
    SUM(Recovered) AS 'Total Recovered'
FROM covid_stats;



-- Q11. Check how corona virus spread out with respect to confirmed case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    SUM(Confirmed) AS 'Total Confirmed', 
    AVG(Confirmed) AS 'Average Confirmed', 
    VARIANCE(Confirmed) AS 'Variance Confirmed', 
    STDDEV(Confirmed) AS 'StdDev Confirmed'
FROM 
    covid_stats;



-- Q12. Check how corona virus spread out with respect to death case per month
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    SUM(Deaths) AS 'Total Deaths', 
    AVG(Deaths) AS 'Average Deaths', 
    VARIANCE(Deaths) AS 'Variance Deaths', 
    STDDEV(Deaths) AS 'StdDev Deaths'
FROM 
    covid_stats;



-- Q13. Check how corona virus spread out with respect to recovered case
--      (Eg.: total confirmed cases, their average, variance & STDEV )
SELECT 
    SUM(Recovered) AS 'Total Recovered', 
    AVG(Recovered) AS 'Average Recovered', 
    VARIANCE(Recovered) AS 'Variance Recovered', 
    STDDEV(Recovered) AS 'StdDev Recovered'
FROM 
    covid_stats;

SELECT *
FROM covid_stats;

-- Q14. Find Country having highest number of the Confirmed case
SELECT CountryRegion, MAX(Confirmed) AS 'Highest Confirmed'
FROM covid_stats
GROUP BY CountryRegion
ORDER BY MAX(Confirmed) DESC
LIMIT 1;


-- Q15. Find Country having lowest number of the death case
SELECT CountryRegion, MIN(Deaths) AS 'Lowest Death'
FROM covid_stats
GROUP BY CountryRegion
ORDER BY MIN(Deaths) DESC;



-- Q16. Find top 5 countries having highest recovered case
SELECT CountryRegion, MAX(Recovered) AS 'Top Recovered'
FROM covid_stats
GROUP BY CountryRegion
ORDER BY MAX(Recovered) DESC
LIMIT 5;


