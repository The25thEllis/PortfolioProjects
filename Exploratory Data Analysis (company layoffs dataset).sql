-- Exploratory Data Analysis

-- Here we are jsut going to explore the data and find trends or patterns or anything interesting like outliers


select *
from layoffs_staging2;

select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging2;

-- Which companies had 1 which is basically 100 percent of they company laid off also ordering by funds raised to see how big the companies were
select *
from layoffs_staging2
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- companies with the most total laid offs

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by 2 desc;

-- industries with the most total laid offs

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by 2 desc;

-- countries with the most total laid offs

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by 2 desc;

-- year with the most total laid offs

select year(`date`), sum(total_laid_off)
from layoffs_staging2
where year(`date`) is not null
group by year(`date`)
order by 1 desc;

-- stage with the most total laid offs

select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by 2 desc;

-- layoffs per month 

SELECT substring(`date`,1,7) as `MONTH`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
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

select company, YEAR(`date`), sum(total_laid_off)
from layoffs_staging2
group by company, YEAR(`date`)
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


































