-- World Layoffs: Data Cleaning Project
-- Steps:
-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Handle Null or Blank Values
-- 4. Remove Unnecessary Columns

SET SQL_SAFE_UPDATES = 0;

-- Create a staging table to preserve raw data
CREATE TABLE layoffs_staging LIKE layoffs;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- ==========================================
-- 1. REMOVE DUPLICATES
-- ==========================================

-- Identify duplicates using ROW_NUMBER()
WITH duplicate_cte AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

-- Create a second staging table with a row_num column to delete duplicates
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company, location, industry, total_laid_off, 
                        percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM layoffs_staging;

-- Verify and remove duplicate rows
SELECT * FROM layoffs_staging2 WHERE row_num > 1;

DELETE FROM layoffs_staging2
WHERE row_num > 1;

-- ==========================================
-- 2. STANDARDIZE THE DATA
-- ==========================================

-- Trim whitespace from company names
UPDATE layoffs_staging2
SET company = TRIM(company);

-- Standardize industry labels
UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Remove trailing periods from country names
UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- Convert date strings to proper DATE format
UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

-- ==========================================
-- 3. HANDLE NULL OR BLANK VALUES
-- ==========================================

-- Convert blank industry strings to NULL
UPDATE layoffs_staging2
SET industry = NULL
WHERE TRIM(industry) = '';

-- Populate missing industry values using self-join on company
UPDATE layoffs_staging2 t1
JOIN layoffs_staging2 t2
    ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- Remove rows with no usable layoff metrics
DELETE FROM layoffs_staging2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- ==========================================
-- 4. REMOVE UNNECESSARY COLUMNS
-- ==========================================

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SET SQL_SAFE_UPDATES = 1;