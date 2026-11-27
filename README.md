# world-layoffs-sql-analysis
Data cleaning and exploratory data analysis (EDA) of global tech layoffs using MySQL.
# World Layoffs: SQL Data Cleaning & Exploratory Data Analysis

An end-to-end MySQL project focused on cleaning a raw global layoffs dataset and performing Exploratory Data Analysis (EDA) to uncover trends across companies, industries, countries, and funding stages.

## Tools & SQL Concepts Used
* **Database:** MySQL / MySQL Workbench
* **Techniques:** Common Table Expressions (CTEs), Window Functions (`ROW_NUMBER()`, `DENSE_RANK()`), Self-Joins, Staging Tables, String & Date Formatting, Aggregations, and Rolling Totals.

## Repository Structure
```text
├── data_cleaning.sql               # Full data cleaning and standardization script
├── exploratory_data_analysis.sql   # EDA queries and trend analysis
└── README.md                       # Project documentation
```

## Phase 1: Data Cleaning (`data_cleaning.sql`)
To preserve the raw data, all transformations were performed on staging tables (`layoffs_staging` and `layoffs_staging2`) following a structured four-step workflow:

1. **Remove Duplicates:** Used a CTE with `ROW_NUMBER()` partitioned across all columns to identify and delete exact duplicate records.
2. **Standardize the Data:**
   * Trimmed leading and trailing whitespace from `company` names.
   * Consolidated inconsistent `industry` labels (e.g., merging variations of `Crypto%` into `Crypto`).
   * Cleaned trailing periods from `country` names (e.g., `United States.` → `United States`).
   * Converted `date` strings from `TEXT` to proper `DATE` format using `STR_TO_DATE()`.
3. **Handle Null & Blank Values:**
   * Converted blank `industry` strings to `NULL` and populated missing values using a self-join on matching `company` names.
   * Removed rows where both `total_laid_off` and `percentage_laid_off` were `NULL`, as they contained no usable layoff metrics.
4. **Drop Unnecessary Columns:** Removed the temporary `row_num` helper column to finalize the clean dataset.

## Phase 2: Exploratory Data Analysis (`exploratory_data_analysis.sql`)
The cleaned dataset is analyzed to answer key business questions, including:
* **Overall Impact:** Maximum single-day layoffs, companies with 100% workforce reductions, and total layoffs by company, industry, and country.
* **Time-Series Trends:** Yearly layoff totals and monthly rolling totals using window functions.
* **Top Performers by Year:** Ranking the top 5 companies with the highest layoffs each year using chained CTEs and `DENSE_RANK()`.
* **Funding Stage Analysis:** Comparing layoff severity across startup and post-IPO funding stages.

*(Update this section with 3–5 specific findings/numbers once your EDA queries are complete.)*

## How to Run
1. Import the raw `layoffs.csv` dataset into a MySQL database as a table named `layoffs`.
2. Run `data_cleaning.sql` to generate the cleaned `layoffs_staging2` table.
3. Run `exploratory_data_analysis.sql` against `layoffs_staging2` to reproduce the analysis.

## Acknowledgements
The data cleaning workflow in this project was guided by **Alex The Analyst's** SQL Data Cleaning series and expanded with additional exploratory analysis.
