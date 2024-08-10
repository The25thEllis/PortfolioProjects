-- Exploratory Data Analysis

SELECT 
    *
FROM
    layoffs_staging2;

SELECT 
    MAX(total_laid_off), MAX(percentage_laid_off)
FROM
    layoffs_staging2;

-- Which companies had 1 which is basically 100 percent of they company laid off also ordering by funds raised to see how big the companies were
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- companies with the most total laid offs

SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- industries with the most total laid offs

SELECT 
    industry, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- countries with the most total laid offs

SELECT 
    country, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- year with the most total laid offs

SELECT 
    YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
WHERE
    YEAR(`date`) IS NOT NULL
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- stage with the most total laid offs

SELECT 
    stage, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- layoffs per month 

SELECT 
    SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off)
FROM
    layoffs_staging2
WHERE
    SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

-- Rolling total of layoffs per month

WITH Rolling_Total as 
(SELECT substring(`date`,1,7) as `MONTH`, sum(total_laid_off) as total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
GROUP BY `MONTH`
ORDER BY 1 ASC
)
select `MONTH`, total_off, sum(total_off) over(order by `MONTH`) as rolling_total
from Rolling_Total;

-- Company layoffs per year

SELECT 
    company, YEAR(`date`), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company , YEAR(`date`)
ORDER BY 3 DESC;

-- Ranking companies with the most layoffs per year (top 5 per year)

with Company_Year (company, years, total_laid_off) as
(
select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
), Company_Year_Rank as
(select *, DENSE_RANK() over (partition by years order by total_laid_off desc) as Ranking
from Company_Year
where years IS NOT NULL
)
SELECT * 
from Company_Year_Rank
where Ranking <=5;

-- Ranking industries with the most layoffs per year (top 5 per year)

with Industry_Year (industry, years, total_laid_off) as
(
select industry, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by industry, YEAR(`date`)
), Industry_Year_Rank as
(select *, DENSE_RANK() over (partition by years order by total_laid_off desc) as Ranking
from Industry_Year
where years IS NOT NULL
)
SELECT * 
from Industry_Year_Rank
where Ranking <=5;

-- Ranking countries with the most layoffs per year (top 5 per year)

with Country_Year (country, years, total_laid_off) as
(
select country, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by country, YEAR(`date`)
), country_Year_Rank as
(select *, DENSE_RANK() over (partition by years order by total_laid_off desc) as Ranking
from country_Year
where years IS NOT NULL
)
SELECT * 
from country_Year_Rank
where Ranking <=5;


































