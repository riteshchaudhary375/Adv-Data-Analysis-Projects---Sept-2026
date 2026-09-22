
-- STEP 1 — Create a Database
-- Open SQL Server Management Studio (SSMS).
CREATE DATABASE EmployeeDataDB;

-- select database
USE EmployeeDataDB;


/*
STEP 2 — First Understand Your CSV

CSV has these 11 columns:

Column	        Example	        Expected SQL type
EMPLOYEE_ID	    100	            INT
FIRST_NAME	    Steven	        VARCHAR
LAST_NAME	    King	        VARCHAR
EMAIL	        SKING	        VARCHAR
PHONE_NUMBER	515.123.4567	VARCHAR
HIRE_DATE	    6/17/2003	    VARCHAR
JOB_ID	        AD_PRES	        VARCHAR
SALARY	        24000	        DECIMAL
COMMISSION_PCT	NULL	        DECIMAL
MANAGER_ID	    NULL / 100	    INT
DEPARTMENT_ID	90	            INT
*/






/*
STEP 3 — Create a Raw/Staging Table

This is an important professional data-cleaning practice.
We don't immediately put the CSV into final production table.

First create a raw/staging table.
*/
CREATE TABLE Employees_Raw
    (
        EMPLOYEE_ID       VARCHAR(50),
        FIRST_NAME        VARCHAR(100),
        LAST_NAME         VARCHAR(100),
        EMAIL             VARCHAR(100),
        PHONE_NUMBER      VARCHAR(50),
        HIRE_DATE         VARCHAR(50),
        JOB_ID            VARCHAR(50),
        SALARY            VARCHAR(50),
        COMMISSION_PCT    VARCHAR(50),
        MANAGER_ID        VARCHAR(50),
        DEPARTMENT_ID     VARCHAR(50)
    );
/*
Why VARCHAR for everything initially?
Because this is the raw CSV layer.

For example:
    6/17/2003
    24000
    NaN
    100.0

We don't want SQL Server to reject the entire import because one value isn't in the expected format.
We'll clean and convert these later.
*/






/*
STEP 4 — Load Employees.csv

There are several ways to import CSV into SQL Server.
    SSMS → Import Flat File Wizard

-- Load Employees.csv

Right-click DB -> Tasks -> Import Flat Files -> Select your file
*/

-- using sql query
BULK INSERT Employees_Raw
FROM 'C:\Users\WINDOWS10\Desktop\Adv Data Analysis Projects - Sept 2026\3. SQL Data Cleaning\Employees.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,                  -- 2 skips the header row; use 1 if there is no header
    FIELDTERMINATOR = ',',         -- The delimiter separating columns
    ROWTERMINATOR = '\n',          -- The character separating rows (usually a newline)
    TABLOCK                        -- Optional: Locks the table during import for better performance
);




-- STEP 5 — Verify the Imported Data
SELECT * FROM Employees_Raw; -- 111 rows x 11 columns

-- check number of rows:
SELECT COUNT(*) AS Total_Rows
FROM Employees_Raw;



-- STEP 6 — Inspect Column Structure
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employees_Raw';




-- STEP 7 — Look at the First Records
/*
Python:
df.head()
*/

SELECT TOP 5 *
FROM Employees_Raw;




-- STEP 8 — Check Duplicate Data
/*
Python
df[df.duplicated(subset='EMPLOYEE_ID')]
*/

SELECT
    EMPLOYEE_ID,
    COUNT(*) AS Duplicate_Count
FROM Employees_Raw
GROUP BY EMPLOYEE_ID
HAVING COUNT(*) > 1;



-- STEP 9 — See the Complete Duplicate Records
SELECT *
FROM Employees_Raw
WHERE EMPLOYEE_ID = '203';



-- STEP 10 — Remove Duplicate Records
/*
ROW_NUMBER()
First identify duplicates:
rn = 1 means: keep
rn > 1 means: duplicate -> remove
*/
WITH DuplicateCTE AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY EMPLOYEE_ID ORDER BY EMPLOYEE_ID) AS rn
    FROM Employees_Raw
)
SELECT *
FROM DuplicateCTE
WHERE rn > 1;




-- STEP 11 — Delete the Duplicate
-- After verifying the duplicate:
WITH DuplicateCTE AS (
    SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY EMPLOYEE_ID ORDER BY EMPLOYEE_ID) AS rn
    FROM Employees_Raw
)
DELETE FROM DuplicateCTE
WHERE rn > 1;

-- now check
SELECT
    EMPLOYEE_ID,
    COUNT(*) AS Total
FROM Employees_Raw
GROUP BY EMPLOYEE_ID
HAVING COUNT(*) > 1;

-- If nothing is returned: No Duplicates





-- STEP 12 — Check NULL Values
/*
Python
df.isnull().sum()
*/

-- SQL Server doesn't have a direct equivalent, so we check each columns using 'SUM CASE'.
SELECT
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN EMPLOYEE_ID IS NULL OR EMPLOYEE_ID = '' THEN 1 ELSE 0 END) AS EMPLOYEE_ID_NULL,
    SUM(CASE WHEN FIRST_NAME IS NULL OR FIRST_NAME = '' THEN 1 ELSE 0 END) AS FIRST_NAME_NULL,
    SUM(CASE WHEN LAST_NAME IS NULL OR LAST_NAME = '' THEN 1 ELSE 0 END) AS LAST_NAME_NULL,
    SUM(CASE WHEN EMAIL IS NULL OR EMAIL = '' THEN 1 ELSE 0 END) AS EMAIL_NULL,
    SUM(CASE WHEN PHONE_NUMBER IS NULL OR PHONE_NUMBER = '' THEN 1 ELSE 0 END) AS PHONE_NULL,
    SUM(CASE WHEN HIRE_DATE IS NULL OR HIRE_DATE = '' THEN 1 ELSE 0 END) AS HIRE_DATE_NULL,
    SUM(CASE WHEN JOB_ID IS NULL OR JOB_ID = '' THEN 1 ELSE 0 END) AS JOB_ID_NULL,
    SUM(CASE WHEN SALARY IS NULL OR SALARY = '' THEN 1 ELSE 0 END) AS SALARY_NULL,
    SUM(CASE WHEN COMMISSION_PCT IS NULL OR COMMISSION_PCT = '' THEN 1 ELSE 0 END) AS COMMISSION_NULL,
    SUM(CASE WHEN MANAGER_ID IS NULL OR MANAGER_ID = '' THEN 1 ELSE 0 END) AS MANAGER_NULL,
    SUM(CASE WHEN DEPARTMENT_ID IS NULL OR DEPARTMENT_ID = '' THEN 1 ELSE 0 END) AS DEPARTMENT_NULL
FROM Employees_Raw;





-- STEP 13 — Calculate Missing Percentage
-- according to handling NULL values, if column have 70-75 % NULL then we drop the column.

-- For COMMISSION_PCT: 72 missing out of 107 total
-- Percentage: 72 / 107 * 100 = 67.29%
-- So it is highly incomplete, but it is slightly below your stated 70–75% threshold.
-- So for demo we fill the NULL values.



-- STEP 14 — Calculate Mean of COMMISSION_PCT
/*
Python
df['COMMISSION_PCT'].mean() => 0.22
*/

SELECT
    AVG(CAST(COMMISSION_PCT AS DECIMAL(10,4))) AS Commission_Mean
FROM Employees_Raw
WHERE COMMISSION_PCT IS NOT NULL
  AND COMMISSION_PCT <> '';




-- STEP 15 — Check Skewness
/* Pandas result -> 0.09661736135041571
Rule: 
0 to 0.5 → Mean
less than 0 or greater than 0.5 → Median

here result lies between 0 - 0.5 which suggest to keep Mean value.
*/



-- *******************************************************





-- STEP 16 — Fill COMMISSION_PCT
UPDATE Employees_Raw
SET COMMISSION_PCT = '0.22'
WHERE COMMISSION_PCT IS NULL
   OR LTRIM(RTRIM(COMMISSION_PCT)) = '';

-- verify
SELECT *
FROM Employees_Raw
WHERE COMMISSION_PCT IS NULL
   OR LTRIM(RTRIM(COMMISSION_PCT)) = '';





-- STEP 17 — Find the Mode of MANAGER_ID
-- Pandas result: MANAGER_ID mode = 100
SELECT TOP 1
    MANAGER_ID,
    COUNT(*) AS Frequency
FROM Employees_Raw
WHERE MANAGER_ID IS NOT NULL
  AND LTRIM(RTRIM(MANAGER_ID)) <> ''
GROUP BY MANAGER_ID
ORDER BY COUNT(*) DESC;






-- STEP 18 — Find Mode of DEPARTMENT_ID
-- Pandas result: DEPARTMENT_ID mode = 50
SELECT TOP 1
    DEPARTMENT_ID,
    COUNT(*) AS Frequency
FROM Employees_Raw
WHERE DEPARTMENT_ID IS NOT NULL
  AND LTRIM(RTRIM(DEPARTMENT_ID)) <> ''
GROUP BY DEPARTMENT_ID
ORDER BY COUNT(*) DESC;





-- STEP 19 — Fill MANAGER_ID
-- Mode = 100
UPDATE Employees_Raw
SET MANAGER_ID = '100'
WHERE MANAGER_ID IS NULL
   OR LTRIM(RTRIM(MANAGER_ID)) = '';




-- STEP 20 — Fill DEPARTMENT_ID
-- Mode = 50
UPDATE Employees_Raw
SET DEPARTMENT_ID = '50'
WHERE DEPARTMENT_ID IS NULL
   OR LTRIM(RTRIM(DEPARTMENT_ID)) = '';




-- STEP 21 — Verify NULL Values Again
SELECT
    SUM(CASE WHEN COMMISSION_PCT IS NULL OR LTRIM(RTRIM(COMMISSION_PCT)) = '' THEN 1 ELSE 0 END) AS COMMISSION_NULL,
    SUM(CASE WHEN MANAGER_ID IS NULL OR LTRIM(RTRIM(MANAGER_ID)) = '' THEN 1 ELSE 0 END) AS MANAGER_NULL,
    SUM(CASE WHEN DEPARTMENT_ID IS NULL OR LTRIM(RTRIM(DEPARTMENT_ID)) = '' THEN 1 ELSE 0 END) AS DEPARTMENT_NULL
FROM Employees_Raw;





-- STEP 22 — Remove Unwanted Spaces
/*
Pandas: 
    strip()
    lstrip()
    rstrip()

SQL Server:
    LTRIM()
    RTRIM()
    TRIM()
*/
SELECT
    TRIM(FIRST_NAME) AS FIRST_NAME,
    TRIM(LAST_NAME) AS LAST_NAME,
    TRIM(EMAIL) AS EMAIL,
    TRIM(JOB_ID) AS JOB_ID
FROM Employees_Raw;

-- Permanent clean the whitespace
SELECT
    TRIM(FIRST_NAME) AS FIRST_NAME,
    TRIM(LAST_NAME) AS LAST_NAME,
    TRIM(EMAIL) AS EMAIL,
    TRIM(JOB_ID) AS JOB_ID
FROM Employees_Raw;




-- STEP 23 — Check for Spaces
SELECT *
FROM Employees_Raw
WHERE FIRST_NAME <> TRIM(FIRST_NAME)
   OR LAST_NAME <> TRIM(LAST_NAME)
   OR EMAIL <> TRIM(EMAIL)
   OR JOB_ID <> TRIM(JOB_ID);
-- If nothing appears, those fields don't have leading/trailing spaces.





-- STEP 24 — Replace Unwanted Characters
/*
Python -> replace()

SQL -> REPLACE()
*/
-- e.g., 
SELECT PHONE_NUMBER, REPLACE(PHONE_NUMBER, '.', '') AS Phone_Cleaned
FROM Employees_Raw;


-- if desired format is: 515-123-4567
UPDATE Employees_Raw
SET PHONE_NUMBER =
    REPLACE(PHONE_NUMBER, '.', '-');

-- check
SELECT * FROM Employees_Raw;





-- STEP 25 — Convert Data Types
/*
Raw data currently has everything as text.
Now create the properly typed table.
*/
CREATE TABLE Employees_Clean
    (
        EMPLOYEE_ID       INT,
        FIRST_NAME        VARCHAR(100),
        LAST_NAME         VARCHAR(100),
        EMAIL             VARCHAR(100),
        PHONE_NUMBER      VARCHAR(50),
        HIRE_DATE         DATE,
        JOB_ID            VARCHAR(50),
        SALARY            DECIMAL(12,2),
        COMMISSION_PCT    DECIMAL(5,2),
        MANAGER_ID        INT,
        DEPARTMENT_ID     INT
    );






-- STEP 26 — Insert Cleaned Data
/*
Use TRY_CONVERT().
This is safer than CAST() because invalid values become NULL rather than causing 
the entire query to fail.
*/
INSERT INTO Employees_Clean
(
    EMPLOYEE_ID,
    FIRST_NAME,
    LAST_NAME,
    EMAIL,
    PHONE_NUMBER,
    HIRE_DATE,
    JOB_ID,
    SALARY,
    COMMISSION_PCT,
    MANAGER_ID,
    DEPARTMENT_ID
)
SELECT
    TRY_CONVERT(INT, EMPLOYEE_ID),
    TRIM(FIRST_NAME),
    TRIM(LAST_NAME),
    TRIM(EMAIL),
    TRIM(PHONE_NUMBER),
    TRY_CONVERT(DATE, HIRE_DATE),
    TRIM(JOB_ID),
    TRY_CONVERT(DECIMAL(12,2), SALARY),
    TRY_CONVERT(DECIMAL(5,2), COMMISSION_PCT),
    TRY_CONVERT(INT, MANAGER_ID),
    TRY_CONVERT(INT, DEPARTMENT_ID)
FROM Employees_Raw;






-- STEP 27 — Verify Data Types
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Employees_Clean';


-- NOTE: This is similar to type-conversion concept in Pandas.




-- TEP 28 — Check the Final Data
SELECT * FROM Employees_Clean;

SELECT COUNT(*) AS Total_Rows
FROM Employees_Clean;




-- STEP 29 — Check Remaining NULL Values
SELECT
    SUM(CASE WHEN EMPLOYEE_ID IS NULL THEN 1 ELSE 0 END) AS EMPLOYEE_ID_NULL,
    SUM(CASE WHEN FIRST_NAME IS NULL THEN 1 ELSE 0 END) AS FIRST_NAME_NULL,
    SUM(CASE WHEN LAST_NAME IS NULL THEN 1 ELSE 0 END) AS LAST_NAME_NULL,
    SUM(CASE WHEN EMAIL IS NULL THEN 1 ELSE 0 END) AS EMAIL_NULL,
    SUM(CASE WHEN PHONE_NUMBER IS NULL THEN 1 ELSE 0 END) AS PHONE_NULL,
    SUM(CASE WHEN HIRE_DATE IS NULL THEN 1 ELSE 0 END) AS HIRE_DATE_NULL,
    SUM(CASE WHEN JOB_ID IS NULL THEN 1 ELSE 0 END) AS JOB_ID_NULL,
    SUM(CASE WHEN SALARY IS NULL THEN 1 ELSE 0 END) AS SALARY_NULL,
    SUM(CASE WHEN COMMISSION_PCT IS NULL THEN 1 ELSE 0 END) AS COMMISSION_NULL,
    SUM(CASE WHEN MANAGER_ID IS NULL THEN 1 ELSE 0 END) AS MANAGER_NULL,
    SUM(CASE WHEN DEPARTMENT_ID IS NULL THEN 1 ELSE 0 END) AS DEPARTMENT_NULL
FROM Employees_Clean;




-- STEP 30 — Check Duplicate Employee IDs Again
SELECT
    EMPLOYEE_ID,
    COUNT(*) AS Total
FROM Employees_Clean
GROUP BY EMPLOYEE_ID
HAVING COUNT(*) > 1;






-- STEP 31 — Feature Engineering
-- columns can be combined or split according to requirements
-- e.g., For example, combine first and last name:
SELECT
    EMPLOYEE_ID,
    FIRST_NAME,
    LAST_NAME,
    CONCAT(FIRST_NAME, ' ', LAST_NAME) AS FULL_NAME
FROM Employees_Clean;



