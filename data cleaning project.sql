-- SQL Project Data Cleaning

SELECT 
    *
FROM
    layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove Unnecessary Columns

CREATE TABLE layoffs_staging LIKE layoffs;

INSERT layoffs_staging
select *
from layoffs;

-- 1. Remove Duplicates

SELECT 
    *
FROM
    layoffs_staging
;

select *, 
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

WITH duplicate_cte AS 
(
select *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging
)

SELECT *
FROM duplicate_cte
WHERE row_num > 1;


CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT DEFAULT NULL,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT DEFAULT NULL,
    `row_num` INT
)  ENGINE=INNODB DEFAULT CHARSET=UTF8MB4 COLLATE = UTF8MB4_0900_AI_CI;

SELECT 
    *
FROM
    layoffs_staging2;

insert into layoffs_staging2
select *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
from layoffs_staging;



DELETE FROM layoffs_staging2 
WHERE
    row_num > 1;

SELECT 
    *
FROM
    layoffs_staging2;

-- 2. Standardize Data


SELECT 
    company, TRIM(company)
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    company = TRIM(company);

SELECT DISTINCT
    industry
FROM
    layoffs_staging2;

-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto

UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry LIKE 'Crypto%';

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.

SELECT DISTINCT
    country, TRIM(TRAILING '.' FROM country)
FROM
    layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country)
WHERE
    country LIKE 'United States%';

-- Let's also fix the date columns:

SELECT 
    `date`
FROM
    layoffs_staging2;

UPDATE layoffs_staging2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

alter table layoffs_staging2
modify column `date` date;


SELECT 
    *
FROM
    layoffs_staging2;


-- if we look at industry it looks like we have some null and empty rows, let's take a look at these
SELECT DISTINCT
    industry
FROM
    world_layoffs.layoffs_staging2
ORDER BY industry;

-- we should set the blanks to nulls since those are typically easier to work with
UPDATE layoffs_staging2 
SET 
    industry = NULL
WHERE
    industry = '';
 
 
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = '';

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company = 'Airbnb';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

SELECT 
    t1.industry, t2.industry
FROM
    layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company
WHERE
    (t1.industry IS NULL OR t1.industry = '')
        AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;

-- and if we check it looks like Bally's was the only one without a populated row to populate this null values
SELECT 
    *
FROM
    world_layoffs.layoffs_staging2
WHERE
    industry IS NULL OR industry = ''
ORDER BY industry;

-- 4. remove any columns and rows we need to

SELECT 
    *
FROM
    layoffs_staging2;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;

-- Delete Useless data we can't really use

DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

alter table layoffs_staging2
drop column row_num;

SELECT 
    *
FROM
    layoffs_staging2











