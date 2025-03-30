SELECT *
FROM layoffs;

-- Duplicating the original dataset

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT * 
FROM layoffs_staging;

INSERT layoffs_staging
SELECT *
FROM layoffs;

-- 1. Removing Duplicates

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, country, stage, funds_raised_millions)
AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, country, stage, funds_raised_millions)
AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;




CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging2
WHERE row_num > 1;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, 
percentage_laid_off, `date`, country, stage, funds_raised_millions)
AS row_num
FROM layoffs_staging;


DELETE
FROM layoffs_staging2
WHERE row_num > 1;

-- Standardizing Data

SELECT company, (TRIM(company))
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = (TRIM(company));


-- Updating the industry column
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country);


-- Changing the date format from text to date

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- Removing null and blank values

SELECT *
FROM layoffs_staging2
WHERE industry IS NULL 
OR industry = '';

SELECT *
FROM layoffs_staging2
WHERE company = 'Airbnb';

UPDATE layoffs_staging2
SET industry = 'Travel'
WHERE company = 'Airbnb';

SELECT *
FROM layoffs_staging2
WHERE company = 'Carvana';

UPDATE layoffs_staging2
SET industry = 'Transportation'
WHERE company = 'Carvana';

SELECT *
FROM layoffs_staging2
WHERE company = 'Juul';

UPDATE layoffs_staging2
SET industry = 'Consumer'
WHERE company = 'Juul';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

-- Deleting unimportant columns

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT DISTINCT location, country
FROM layoffs_staging2
WHERE country = 'United States';

UPDATE layoffs_staging2
SET country = 'United Arab Emirates'
WHERE location = 'Dubai';

SELECT  location, country
FROM layoffs_staging2
WHERE location = 'Dubai';
