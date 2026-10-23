-- use database
USE master;

-- drop database
DROP DATABASE IF EXISTS MedicareInpatient2017;

-- create database
CREATE DATABASE MedicareInpatient2017;

-- use database
USE MedicareInpatient2017;







-- Step 1: create new table for bulk insert raw data
-- drop table
DROP TABLE IF EXISTS Staging_Raw;

-- Create Table to store raw data from .xlsx file
CREATE TABLE Staging_Raw (
    DRG_Code VARCHAR(30),
    DRG_Definition VARCHAR(100), -- file does not contain underscore in column name so modifying in files (.csv) as well as in column name
	Patient_Name VARCHAR(50),
    District VARCHAR(50),
    Doctor VARCHAR(50),
    Admission_Date VARCHAR(50),
    Discharge_date VARCHAR(50),
    Admitted_Days VARCHAR(50),
    Gender VARCHAR(10),
    Age VARCHAR(10),
    Charge VARCHAR(25),
    G_Amount VARCHAR(25),
    "Discount(%)" VARCHAR(25),
    D_Amt VARCHAR(25),
    "G_AMT_!" VARCHAR(25),
    VAT VARCHAR(25),
    Net_Amount VARCHAR(25),
    Has_Cured VARCHAR(10),
    IS_DEAD VARCHAR(10),
    Year VARCHAR(25),
    month VARCHAR(25),
    Doctor_Rate VARCHAR(25)
);

-- fetch tables data
SELECT * FROM Staging_Raw;


/*
got error on date format: 
in file = DD-MM-YYYY
SQL Server Accept = YYYY-MM-DD 
*/

-- bulk insert from .csv file
BULK INSERT Staging_Raw
FROM 'C:\Users\WINDOWS10\Desktop\Adv Data Analysis Projects - Sept 2026\5. SQL ETL\Data Source\Medicare-Inpatient-2017.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = '|',
    ROWTERMINATOR = '\n'
);
/*
(196325 rows affected)
.xlxs file: 196326 (1 is header)
*/

-- fetch tables data
SELECT * FROM Staging_Raw;







-- Step 2: checking data's quality
-- Check Null or whitespace conain

-- Specific column
-- column 1: DRG_Code
-- check null value
SELECT DRG_Code
FROM Staging_Raw
WHERE DRG_Code IS NULL;
-- no null record found



-- column 2: DRG_Definition
-- check null value
SELECT DRG_Definition
FROM Staging_Raw
WHERE DRG_Definition IS NULL;
-- no null record found

-- check unwanted spaces
SELECT DRG_Definition
FROM Staging_Raw
WHERE DRG_Definition != TRIM(DRG_Definition);
-- no unwanted spaces


-- column 3: Patient_Name
-- check null value
SELECT Patient_Name
FROM Staging_Raw
WHERE Patient_Name IS NULL;
-- no null record found

-- check unwanted spaces
SELECT Patient_Name
FROM Staging_Raw
WHERE Patient_Name != TRIM(Patient_Name);
-- no unwanted spaces



-- column 4: District
-- check null value
SELECT District
FROM Staging_Raw
WHERE District IS NULL;
-- no null record found

-- check unwanted spaces
SELECT District
FROM Staging_Raw
WHERE District != TRIM(District);
-- no unwanted spaces



-- column 5: Doctor
-- check null value
SELECT Doctor
FROM Staging_Raw
WHERE Doctor IS NULL;
-- no null record found

-- check unwanted spaces
SELECT Doctor
FROM Staging_Raw
WHERE Doctor != TRIM(Doctor);
-- no unwanted spaces



-- column 6: Admission_Date
-- check null value
SELECT Admission_Date
FROM Staging_Raw
WHERE Admission_Date IS NULL;
-- no null record found



-- column 7: Discharge_Date
-- check null value
SELECT Discharge_Date
FROM Staging_Raw
WHERE Discharge_Date IS NULL;
-- no null record found



-- column 8: Admitted_Days
-- check null value
SELECT Admitted_Days
FROM Staging_Raw
WHERE Admitted_Days IS NULL;
-- no null record found

-- check value 0 or less
SELECT Admitted_Days
FROM Staging_Raw
WHERE Admitted_Days = 0 OR Admitted_Days < 0;
-- no null record found



-- column 9: Gender
-- check null value
SELECT Gender
FROM Staging_Raw
WHERE Gender IS NULL;
-- no null record found

-- check unwanted spaces
SELECT Gender
FROM Staging_Raw
WHERE Gender != TRIM(Gender);
-- no unwanted spaces

-- get distinct gender
SELECT DISTINCT Gender FROM Staging_Raw;



-- column 10: Age
-- check null value
SELECT Age
FROM Staging_Raw
WHERE Age IS NULL;
-- no null record found

-- check age less than 1 and greater than 100
SELECT Age
FROM Staging_Raw
WHERE Age <= 0; -- or Age < 1;
-- no age less or equal to 0

SELECT Age
FROM Staging_Raw
WHERE Age > 100;
-- no age > 100



-- column 11: Charge
-- check null value
SELECT Charge
FROM Staging_Raw
WHERE Charge IS NULL;
-- no null record found

-- check value less than 1
SELECT Charge
FROM Staging_Raw
WHERE Charge < 1;
-- no null record found

select * from Staging_Raw;

-- column 12: Gross_Amount
-- check null value
SELECT G_Amount
FROM Staging_Raw
WHERE G_Amount IS NULL;
-- no null record found

-- check value less 1
SELECT G_Amount
FROM Staging_Raw
WHERE G_Amount < 1;
-- no null record found



-- column 13: [Discount(%)]
-- check null value
SELECT [Discount(%)]
FROM Staging_Raw
WHERE [Discount(%)] IS NULL;
-- no null record found

-- check 3 or more digit after decimal
	/*
		Allowed:
		--------
		5.00 → length 1 → allowed
		15.00 → length 2 → allowed
		05.00 → length 2 → allowed
		Excluded:
		---------
		122.00 → length 3 → excluded
		1234.00 → length 4 → excluded
	*/
SELECT [Discount(%)]
FROM Staging_Raw
WHERE 
    CHARINDEX('.', CAST([Discount(%)] AS VARCHAR)) > 0
    AND LEN(
        LEFT(CAST([Discount(%)] AS VARCHAR), CHARINDEX('.', CAST([Discount(%)] AS VARCHAR)) - 1)
    ) NOT BETWEEN 1 AND 2;
-- no record found




-- column 14: Discount_Amount
-- check null value
SELECT D_Amt
FROM Staging_Raw
WHERE D_Amt IS NULL;
-- no null record found



-- column 15: Gross_Amount_With_Discount
-- check null value
SELECT "G_AMT_!"
FROM Staging_Raw
WHERE "G_AMT_!" IS NULL;
-- no null record found



-- column 16: VAT
-- check null value
SELECT VAT
FROM Staging_Raw
WHERE VAT IS NULL;
-- no null record found



-- column 17: Net_Amount_With_VAT
-- check null value
SELECT Net_Amount
FROM Staging_Raw
WHERE Net_Amount IS NULL;
-- no null record found



-- column 18: Has_Cured
-- check null value
SELECT Has_Cured
FROM Staging_Raw
WHERE Has_Cured IS NULL;
-- no null record found

-- distinct Has_Cured value
SELECT DISTINCT Has_Cured
FROM Staging_Raw;
-- YES, NO



-- column 19: Is_Dead
-- check null value
SELECT Is_Dead
FROM Staging_Raw
WHERE Is_Dead IS NULL;
-- no null record found

-- distinct Has_Cured value
SELECT DISTINCT Is_Dead
FROM Staging_Raw;
-- YES, NO



-- column 20: Year
-- check null value
SELECT Year
FROM Staging_Raw
WHERE Year IS NULL;
-- no null record found

-- check value less than 1990 or greater than current year
SELECT Year
FROM Staging_Raw
WHERE Year < 1990;
-- no record found

SELECT Year
FROM Staging_Raw
WHERE Year > YEAR(GETDATE());
-- no record found



-- column 21: Month
-- check null value
SELECT Month
FROM Staging_Raw
WHERE Month IS NULL;
-- no record found

-- check value less than 1 or greater than 12
SELECT Month
FROM Staging_Raw
WHERE Month < 1;
-- no record found

SELECT Month
FROM Staging_Raw
WHERE Month > 12;
-- no record found



-- column 22: Doctor_Rate
-- check null value
SELECT Doctor_Rate
FROM Staging_Raw
WHERE Doctor_Rate IS NULL;
-- no null record found

-- check value less than 1
SELECT Doctor_Rate
FROM Staging_Raw
WHERE Doctor_Rate < 0.0;
-- no record found


-- To check null or whitespace at a time for all columns
-- get all columns info
SELECT
    -- *
    -- ORDINAL_POSITION,
    COLUMN_NAME
    -- DATA_TYPE,
    -- CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Staging_Raw'
ORDER BY ORDINAL_POSITION;

-- Check null or whitespace values
SELECT *
FROM Staging_Raw
WHERE DRG_Code IS NULL OR TRIM(DRG_Code) = ''
    OR DRG_Definition IS NULL OR TRIM(DRG_Definition) = ''
    OR Patient_Name IS NULL OR TRIM(Patient_Name) = ''
    OR District IS NULL OR TRIM(District) = ''
    OR Doctor IS NULL OR TRIM(Doctor) = ''
    OR Admission_Date IS NULL OR TRIM(Admission_Date) = ''
    OR Discharge_date IS NULL OR TRIM(Discharge_date) = ''
    OR Admitted_Days IS NULL OR TRIM(Admitted_Days) = ''
    OR Gender IS NULL OR TRIM(Gender) = ''
    OR Age IS NULL OR TRIM(Age) = ''
    OR Charge IS NULL OR TRIM(Charge) = ''
    OR G_Amount IS NULL OR TRIM(G_Amount) = ''
    OR 'Discount(%)' IS NULL OR TRIM('Discount(%)') = ''
    OR D_Amt IS NULL OR TRIM(D_Amt) = ''
    OR 'G_AMT_!' IS NULL OR TRIM('G_AMT_!') = ''
    OR VAT IS NULL OR TRIM(VAT) = ''
    OR Net_Amount IS NULL OR TRIM(Net_Amount) = ''
    OR Has_Cured IS NULL OR TRIM(Has_Cured) = ''
    OR IS_DEAD IS NULL OR TRIM(IS_DEAD) = ''
    OR Year IS NULL OR TRIM(Year) = ''
    OR month IS NULL OR TRIM(month) = ''
    OR Doctor_Rate IS NULL OR TRIM(Doctor_Rate) = '';

-- no null or whitespace record found

-- ************************** End checking data's quality: **************************






-- Step 3: create table for correct data types for clean data
-- drop table 
DROP TABLE IF EXISTS Staging_Clean;

-- Create transformed table
CREATE TABLE Staging_Clean (
    DRG_Code INT,
    DRG_Definition VARCHAR(100),
    DRG_Name VARCHAR(100),
    Patient_Name VARCHAR(50),
    District VARCHAR(50),
    Doctor VARCHAR(50),
    Admission_Date DATE,
    Discharge_Date DATE,
    Admitted_Days INT,
    Gender VARCHAR(10),
    Age INT,
    Charge INT,
    G_Amount INT,
    "Discount(%)" DECIMAL(4, 2),
    D_Amt DECIMAL(20, 5),
    "G_AMT_!" DECIMAL(20, 5),
    VAT DECIMAL(20, 5),
    Net_Amount DECIMAL(20, 5),
    Has_Cured VARCHAR(10),
    Is_Dead VARCHAR(10),
    Year INT,
    Month INT,
    Doctor_Rate DECIMAL(2,1)
);
-- fetch
SELECT * FROM Staging_Clean;
-- step 3: insert clean data in table "Staging_Clean"

-- SELECT INTO... statement will insert data as inserted in previous data-type format
-- INSERT INTO... approach is appling because clean table have different data-type columns
INSERT INTO Staging_Clean
(DRG_Code, DRG_Definition, DRG_Name, Patient_Name, District, Doctor, Admission_Date, Discharge_Date,
Admitted_Days, Gender, Age, Charge, G_Amount, [Discount(%)], D_Amt, [G_AMT_!], VAT, Net_Amount,
 Has_Cured, Is_Dead, Year, Month, Doctor_Rate)
SELECT
    CAST(NULLIF(DRG_Code, '') AS INT),
    NULLIF(DRG_Definition, ''),
    LTRIM(SUBSTRING(
        DRG_Definition,
        CHARINDEX('-', DRG_Definition) + 1,
        LEN(DRG_Definition)
    )),
    NULLIF(Patient_Name, ''),
    CAST(NULLIF(District, '') AS VARCHAR(25)),
    CAST(NULLIF(Doctor, '') AS VARCHAR(25)),
    CONVERT(DATE, NULLIF(Admission_Date, ''), 101),
    CONVERT(DATE, NULLIF(Discharge_Date, ''), 101),
    CAST(NULLIF(Admitted_Days, '') AS INT),
    CAST(NULLIF(Gender, '') AS VARCHAR(10)),
    CAST(NULLIF(Age, '') AS INT),
    CAST(NULLIF(Charge, '') AS INT),
    CAST(NULLIF(G_Amount, '') AS INT),
    CAST(NULLIF([Discount(%)], '') AS DECIMAL(4,2)),
    CAST(NULLIF(D_Amt, '') AS DECIMAL(20,5)),
    CAST(NULLIF([G_AMT_!], '') AS DECIMAL(20,5)),
    CAST(NULLIF(VAT, '') AS DECIMAL(20,5)),
    CAST(NULLIF(Net_Amount, '') AS DECIMAL(20,5)),
    CAST(NULLIF(Has_Cured, '') AS VARCHAR(5)),
    CAST(NULLIF(IS_DEAD, '') AS VARCHAR(5)),
    CAST(NULLIF(Year, '') AS INT),
    CAST(NULLIF(Month, '') AS INT),
    CAST(NULLIF(Doctor_Rate, '') AS DECIMAL(2,1))
FROM Staging_Raw; -- 196325

-- fetch records from clean data table
SELECT * FROM Staging_Clean; -- 196,325






-- step 4: updating name format
-- Robertson, Peter => Peter Robertson
UPDATE Staging_Clean
SET Patient_Name = 
    LTRIM(RTRIM(
        SUBSTRING(Patient_Name, CHARINDEX(',', Patient_Name) + 1, LEN(Patient_Name))
    )) 
    + ' ' +
    LTRIM(RTRIM(
        SUBSTRING(Patient_Name, 1, CHARINDEX(',', Patient_Name) - 1)
    ));

-- fetch data
SELECT Patient_Name AS fromCleanTable FROM Staging_Clean;
SELECT Patient_Name AS fromRawTable FROM Staging_Raw;






-- Designing Schema
-- Step 5: Table Separation
-- Table 1: District
CREATE TABLE Dim_District (
    District_ID INT IDENTITY(1,1) PRIMARY KEY,
    District_Code_ID AS (CAST('DIS-' + CAST(District_ID AS VARCHAR(20)) AS VARCHAR(20))) PERSISTED UNIQUE,
    District_Name VARCHAR(50)
);
-- insert
INSERT INTO Dim_District (District_Name)
SELECT DISTINCT District 
FROM Staging_Clean; -- 59





-- Table 2: Doctor
CREATE TABLE Dim_Doctor (
    Doctor_ID INT IDENTITY(1,1) PRIMARY KEY,
    Doctor_Code_ID AS (CAST('DOC-' + CAST(Doctor_ID AS VARCHAR(20)) AS VARCHAR(20))) PERSISTED UNIQUE,
    Doctor_Name VARCHAR(50),
    Doctor_Rate DECIMAL(2,1)
);
-- insert
INSERT INTO Dim_Doctor (Doctor_Name, Doctor_Rate)
SELECT DISTINCT Doctor, Doctor_Rate 
FROM Staging_Clean; -- 29





-- Table 3: DRG_Diagnosis_Related_Group
CREATE TABLE Dim_DRG (
    DRG_Code INT PRIMARY KEY,
    -- DRG_Code_ID AS (CAST('DRG-' + CAST(DRG_ID AS VARCHAR(20)) AS VARCHAR(20))) PERSISTED UNIQUE,
    DRG_Definition VARCHAR(100),
    DRG_Name VARCHAR(100)    
);
-- insert
INSERT INTO Dim_DRG (DRG_Code, DRG_Definition, DRG_Name)
SELECT DISTINCT DRG_Code, DRG_Definition, DRG_Name 
FROM Staging_Clean; -- 563





-- Table 4: Patient
CREATE TABLE Dim_Patient (
    Patient_ID INT IDENTITY (1,1) PRIMARY KEY,
    Patient_Code_ID AS (CAST('PAT-' + CAST(Patient_ID AS VARCHAR(20)) AS VARCHAR(20))) PERSISTED UNIQUE,
    Patient_Name VARCHAR(50),
    Gender VARCHAR(10),
    Age INT,
    Age_Group VARCHAR(50),
    Admission_Date DATE,
    Discharge_Date DATE,
    Admitted_Days INT,
    Year INT,
    Month INT
);
-- Insert UNIQUE patients (using DISTINCT)
INSERT INTO Dim_Patient (Patient_Name, Gender, Age, Age_Group, Admission_Date, Discharge_Date, Admitted_Days, Year, Month)
SELECT DISTINCT
    Patient_Name,
    Gender,
    Age,
    CASE 
        WHEN Age < 1 THEN 'Infant'
        WHEN Age BETWEEN 1 AND 12 THEN 'Child'
        WHEN Age BETWEEN 13 AND 19 THEN 'Teen'
        WHEN Age BETWEEN 20 AND 39 THEN 'Adult'
        WHEN Age BETWEEN 40 AND 59 THEN 'Middle Age'
        WHEN Age >= 60 THEN 'Senior'
        ELSE 'Unknown'
    END AS Age_Group,
    Admission_Date,
    Discharge_Date,
    Admitted_Days,
    Year,
    Month
FROM Staging_Clean; -- 196303
-- WHERE Patient_Name IS NOT NULL;





-- Table 5: Hospitalization
CREATE TABLE Fact_Hospitalization (
    Hospitalization_ID INT IDENTITY(1,1) PRIMARY KEY,
    Hospitalization_Code_ID AS (CAST('HOS-' + CAST(Hospitalization_ID AS VARCHAR(20)) AS VARCHAR(20))) PERSISTED UNIQUE,

    DRG_Code INT,
    Doctor_Code_ID VARCHAR(20),
    Patient_Code_ID VARCHAR(20),
    District_Code_ID VARCHAR(20),

    Charge INT,
    G_Amount INT,
    "Discount(%)" DECIMAL(4, 2),
    D_Amt DECIMAL(20, 5),
    "G_AMT_!" DECIMAL(20, 5),
    VAT DECIMAL(20, 5),
    Net_Amount DECIMAL(20, 5),
    Has_Cured VARCHAR(10),
    Is_Dead VARCHAR(10),
    Year INT,
    Month INT,

    FOREIGN KEY (DRG_Code) REFERENCES Dim_DRG(DRG_Code),
    FOREIGN KEY (Doctor_Code_ID) REFERENCES Dim_Doctor(Doctor_Code_ID),
    FOREIGN KEY (Patient_Code_ID) REFERENCES Dim_Patient(Patient_Code_ID),
    FOREIGN KEY (District_Code_ID) REFERENCES Dim_District(District_Code_ID) 
);

-- insert
INSERT INTO Fact_Hospitalization (Charge, G_Amount, [Discount(%)], D_Amt, [G_AMT_!], VAT, Net_Amount, 
Has_Cured, Is_Dead, Year, Month, DRG_Code, Doctor_Code_ID, Patient_Code_ID, District_Code_ID)
SELECT DISTINCT
    m.Charge, m.G_Amount, m.[Discount(%)], m.D_Amt, m.[G_AMT_!], m.VAT, m.Net_Amount,
    m.Has_Cured, m.Is_Dead, m.Year, m.Month, drg.DRG_Code, doc.Doctor_Code_ID, p.Patient_Code_ID, d.District_Code_ID
FROM Staging_Clean m
INNER JOIN Dim_DRG drg 
    ON m.DRG_Definition = drg.DRG_Definition
    AND m.DRG_Name = drg.DRG_Name
INNER JOIN Dim_Doctor doc
    ON m.Doctor = doc.Doctor_Name 
    AND m.Doctor_Rate = doc.Doctor_Rate
INNER JOIN Dim_Patient p 
    ON m.Patient_Name = p.Patient_Name
    AND m.Gender = p.Gender
    AND m.Age = p.Age
    AND m.Admission_Date = p.Admission_Date
    AND m.Discharge_Date = p.Discharge_Date
    AND m.Admitted_Days = p.Admitted_Days
    AND m.Year = p.Year
    AND m.Month = p.Month
INNER JOIN Dim_District d 
    ON m.District = d.District_Name; -- 196325

-- ************************** Table Separation Complete: **************************







-- ************************** Verification Queries **************************
-- Verify counts match
SELECT 
    (SELECT COUNT(*) FROM Staging_Raw) AS RawMedicareCount,
    (SELECT COUNT(*) FROM Staging_Clean) AS CleanMedicareCount,
    (SELECT COUNT(*) FROM Dim_DRG) AS DRGCount,
    (SELECT COUNT(*) FROM Dim_Doctor) AS DimDoctorCount,
    (SELECT COUNT(*) FROM Dim_Patient) AS DimPatientCount,
    (SELECT COUNT(*) FROM Dim_District) AS DimDistrictCount,
    (SELECT COUNT(*) FROM Fact_Hospitalization) AS FactHospitalizationCount;
/*
RawMedicareCount	CleanMedicareCount	DRGCount	DimDoctorCount	DimPatientCount	DimDistrictCount	FactHospitalizationCount
196325	            196325	            563	        29	            196303	        59	                196325
*/
-- ************************** Verification Queries Complete **************************














/*
Business question:
------------------

1. Which DRG treatments generate the highest revenue?
Question: Which top 20 DRG treatment categories generate the highest total revenue, 
    and how do they rank against other treatments?
*/
SELECT
    drg.DRG_Code,
    drg.DRG_Name,
    COUNT(*) AS Total_Cases,
    SUM(f.Net_Amount) AS Total_Revenue,
    AVG(f.Net_Amount) AS Avg_Revenue_Per_Case,
    RANK() OVER (
        ORDER BY SUM(f.Net_Amount) DESC
    ) AS Revenue_Rank
FROM Fact_Hospitalization f
INNER JOIN Dim_DRG drg
    ON f.DRG_Code = drg.DRG_Code
GROUP BY
    drg.DRG_Code,
    drg.DRG_Name
ORDER BY Revenue_Rank; -- 563 rows

-- or
SELECT TOP 20
    drg.DRG_Code,
    drg.DRG_Name,
    COUNT(*) AS Total_Cases,
    SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue,
    AVG(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Avg_Revenue_Per_Case
FROM Fact_Hospitalization f
INNER JOIN Dim_DRG drg
    ON f.DRG_Code = drg.DRG_Code
GROUP BY
    drg.DRG_Code,
    drg.DRG_Name
ORDER BY
    Total_Revenue DESC;
/*
Business value:
Management can identify the highest-revenue treatment categories and 
use the result for resource allocation, capacity planning and service 
strategy.
*/




/*
2. Which districts are the strongest markets for the hospital?
Question: Which geographic districts contribute the most patients and revenue, 
    and which districts may represent growth opportunities?
*/
SELECT
    d.District_Name,
    COUNT(*) AS Total_Hospitalizations,
    SUM(f.Net_Amount) AS Total_Revenue,
    AVG(f.Net_Amount) AS Avg_Revenue_Per_Case,
    RANK() OVER (ORDER BY SUM(f.Net_Amount) DESC) AS Revenue_Rank,
    RANK() OVER (ORDER BY COUNT(*) DESC) AS Volume_Rank
FROM Fact_Hospitalization f
INNER JOIN Dim_District d
    ON f.District_Code_ID = d.District_Code_ID
GROUP BY d.District_Name
ORDER BY Total_Revenue DESC; -- 59 rows

-- or
SELECT TOP 10
    d.District_Name,
    COUNT(*) AS Total_Hospitalizations,
    SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue,
    AVG(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Avg_Revenue_Per_Case
FROM Fact_Hospitalization f
INNER JOIN Dim_District d
    ON f.District_Code_ID = d.District_Code_ID
GROUP BY
    d.District_Name
ORDER BY
    Total_Revenue DESC;
/*
Business Value:
This can support regional marketing, referral partnerships and service expansion decisions.
*/






/*
3. Which doctors contribute the most revenue while handling significant case volumes?
Which doctors generate the highest revenue while managing a significant number of hospitalizations?
*/
SELECT
    doc.Doctor_Name,
    doc.Doctor_Rate,
    COUNT(*) AS Total_Cases,
    SUM(f.Net_Amount) AS Total_Revenue,
    AVG(f.Net_Amount) AS Avg_Revenue_Per_Case,
    RANK() OVER (ORDER BY SUM(f.Net_Amount) DESC) AS Revenue_Rank
FROM Fact_Hospitalization f
INNER JOIN Dim_Doctor doc
    ON f.Doctor_Code_ID = doc.Doctor_Code_ID
GROUP BY
    doc.Doctor_Name,
    doc.Doctor_Rate
HAVING COUNT(*) >= 100
ORDER BY Revenue_Rank; -- 23 rows

-- or
SELECT
    doc.Doctor_Name,
    doc.Doctor_Rate,
    COUNT(*) AS Total_Cases,
    SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue,
    AVG(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Avg_Revenue_Per_Case
FROM Fact_Hospitalization f
INNER JOIN Dim_Doctor doc
    ON f.Doctor_Code_ID = doc.Doctor_Code_ID
GROUP BY
    doc.Doctor_Name,
    doc.Doctor_Rate
HAVING COUNT(*) >= 100;

/*
Business value:
Useful for workforce planning, workload analysis, capacity management and 
incentive analysis.
*/





/*
4. Which DRGs have high patient volume but relatively low revenue per case?
Question: Which treatments have high demand but comparatively low revenue per hospitalization?
*/
SELECT
    drg.DRG_Code,
    drg.DRG_Name,
    COUNT(*) AS Total_Cases,
    SUM(f.Net_Amount) AS Total_Revenue,
    AVG(f.Net_Amount) AS Avg_Revenue_Per_Case
FROM Fact_Hospitalization f
INNER JOIN Dim_DRG drg
    ON f.DRG_Code = drg.DRG_Code
GROUP BY
    drg.DRG_Code,
    drg.DRG_Name
HAVING COUNT(*) >= 100
ORDER BY
    Avg_Revenue_Per_Case ASC; -- 256 rows

-- or
SELECT
    drg.DRG_Code,
    drg.DRG_Name,
    COUNT(*) AS Total_Cases,
    SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue,
    AVG(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Avg_Revenue_Per_Case
FROM Fact_Hospitalization f
INNER JOIN Dim_DRG drg
    ON f.DRG_Code = drg.DRG_Code
GROUP BY
    drg.DRG_Code,
    drg.DRG_Name
HAVING COUNT(*) >= 100;

/*
Business value:
A high-volume/low-revenue service may require management to investigate 
pricing, reimbursement, operational cost or resource utilization.
*/




/*
5. What is the month-over-month revenue growth trend?
Question: How is hospital revenue changing month-over-month, and which months experienced the strongest growth or decline?
*/
WITH MonthlyRevenue AS
(
    SELECT
        Year, Month,
        SUM(Net_Amount) AS Total_Revenue
    FROM Fact_Hospitalization
    GROUP BY
        Year, Month
),
RevenueWithPrevious AS
(
    SELECT
        Year, Month,
        Total_Revenue,
        LAG(Total_Revenue) OVER (ORDER BY Year, Month) AS Previous_Month_Revenue
    FROM MonthlyRevenue
)
SELECT
    Year, Month,
    Total_Revenue,
    Previous_Month_Revenue,
    Total_Revenue - Previous_Month_Revenue AS Revenue_Change,
    CAST(
        (Total_Revenue - Previous_Month_Revenue) * 100.0 / NULLIF(Previous_Month_Revenue, 0) AS DECIMAL(10,2)
    ) AS Growth_Percentage
FROM RevenueWithPrevious
ORDER BY
    Year, Month; -- 61 rows

-- or
WITH MonthlyRevenue AS
(
    SELECT
        Year,
        Month,
        SUM(CAST(Net_Amount AS DECIMAL(18,2))) AS Total_Revenue
    FROM Fact_Hospitalization
    GROUP BY
        Year,
        Month
),
RevenueWithPrevious AS
(
    SELECT
        Year,
        Month,
        Total_Revenue,
        LAG(Total_Revenue) OVER (
            ORDER BY Year, Month
        ) AS Previous_Month_Revenue
    FROM MonthlyRevenue
)
SELECT
    Year,
    Month,
    Total_Revenue,
    Previous_Month_Revenue,
    Total_Revenue - Previous_Month_Revenue AS Revenue_Change,
    CAST(
        (Total_Revenue - Previous_Month_Revenue) * 100.0
        / NULLIF(Previous_Month_Revenue, 0)
        AS DECIMAL(10,2)
    ) AS Growth_Percentage
FROM RevenueWithPrevious
ORDER BY
    Year,
    Month;

/*
Business value:
Management can identify growth periods, declining periods and seasonal 
demand patterns for staffing and resource planning.
*/





/*
6. Which doctors have unusually high or low cure rates?
Which doctors have the highest and lowest observed cure rates?
*/
SELECT
    doc.Doctor_Name,
    COUNT(*) AS Total_Cases,
    SUM(CASE WHEN f.Has_Cured = 'YES' THEN 1 ELSE 0 END) AS Cured_Cases,
    CAST(SUM(CASE WHEN f.Has_Cured = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)
    ) AS Cure_Rate
FROM Fact_Hospitalization f
INNER JOIN Dim_Doctor doc
    ON f.Doctor_Code_ID = doc.Doctor_Code_ID
GROUP BY doc.Doctor_Name
HAVING COUNT(*) >= 100
ORDER BY Cure_Rate DESC; -- 23 rows

-- or
SELECT
    doc.Doctor_Name,
    COUNT(*) AS Total_Cases,
    SUM(
        CASE
            WHEN f.Has_Cured = 'YES' THEN 1
            ELSE 0
        END
    ) AS Cured_Cases,
    CAST(
        SUM(
            CASE
                WHEN f.Has_Cured = 'YES' THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*)
        AS DECIMAL(10,2)
    ) AS Cure_Rate
FROM Fact_Hospitalization f
INNER JOIN Dim_Doctor doc
    ON f.Doctor_Code_ID = doc.Doctor_Code_ID
GROUP BY
    doc.Doctor_Name
HAVING COUNT(*) >= 100
ORDER BY
    Cure_Rate DESC;

/*
Business value:
Useful as a quality-monitoring indicator, but it should not be interpreted
as proof that one doctor provides better care because diagnosis severity 
and patient mix can differ.
*/







/*
7. How does length of stay affect revenue and operational demand?
How do short-, medium- and long-stay hospitalizations differ in volume and revenue?
*/
SELECT
    CASE
        WHEN p.Admitted_Days BETWEEN 1 AND 3
            THEN 'Short Stay (1-3 Days)'
        WHEN p.Admitted_Days BETWEEN 4 AND 7
            THEN 'Medium Stay (4-7 Days)'
        WHEN p.Admitted_Days BETWEEN 8 AND 14
            THEN 'Long Stay (8-14 Days)'
        ELSE 'Very Long Stay (15+ Days)'
    END AS Stay_Category,
    COUNT(*) AS Total_Hospitalizations,
    SUM(f.Net_Amount) AS Total_Revenue,
    AVG(f.Net_Amount) AS Avg_Revenue_Per_Case,
    AVG(p.Admitted_Days) AS Avg_Length_of_Stay
FROM Fact_Hospitalization f
INNER JOIN Dim_Patient p
    ON f.Patient_Code_ID = p.Patient_Code_ID
GROUP BY
    CASE
        WHEN p.Admitted_Days BETWEEN 1 AND 3
            THEN 'Short Stay (1-3 Days)'
        WHEN p.Admitted_Days BETWEEN 4 AND 7
            THEN 'Medium Stay (4-7 Days)'
        WHEN p.Admitted_Days BETWEEN 8 AND 14
            THEN 'Long Stay (8-14 Days)'
        ELSE 'Very Long Stay (15+ Days)'
    END
ORDER BY Avg_Length_of_Stay; -- 4 rows

-- or
SELECT
    CASE
        WHEN p.Admitted_Days BETWEEN 1 AND 3
            THEN 'Short Stay (1-3 Days)'
        WHEN p.Admitted_Days BETWEEN 4 AND 7
            THEN 'Medium Stay (4-7 Days)'
        WHEN p.Admitted_Days BETWEEN 8 AND 14
            THEN 'Long Stay (8-14 Days)'
        ELSE 'Very Long Stay (15+ Days)'
    END AS Stay_Category,
    COUNT(*) AS Total_Hospitalizations,
    SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue,
    AVG(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Avg_Revenue_Per_Case,
    AVG(CAST(p.Admitted_Days AS DECIMAL(10,2))) AS Avg_Length_of_Stay
FROM Fact_Hospitalization f
INNER JOIN Dim_Patient p
    ON f.Patient_Code_ID = p.Patient_Code_ID
GROUP BY
    CASE
        WHEN p.Admitted_Days BETWEEN 1 AND 3
            THEN 'Short Stay (1-3 Days)'
        WHEN p.Admitted_Days BETWEEN 4 AND 7
            THEN 'Medium Stay (4-7 Days)'
        WHEN p.Admitted_Days BETWEEN 8 AND 14
            THEN 'Long Stay (8-14 Days)'
        ELSE 'Very Long Stay (15+ Days)'
    END
ORDER BY
    MIN(p.Admitted_Days);

/*
Business Value:
Helps with bed capacity, staffing, operational planning and long-stay management.
*/







/*
8. Which DRGs have both high revenue and high mortality?
Which major treatment categories require management attention because they combine substantial financial activity with elevated mortality?
*/
WITH DRG_Performance AS
(
    SELECT
        drg.DRG_Code, drg.DRG_Name,
        COUNT(*) AS Total_Cases,
        SUM(f.Net_Amount) AS Total_Revenue,
        SUM( CASE WHEN f.Is_Dead = 'YES' THEN 1 ELSE 0 END) AS Deaths,
        CAST(SUM(CASE WHEN f.Is_Dead = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)
        ) AS Mortality_Rate
    FROM Fact_Hospitalization f
    INNER JOIN Dim_DRG drg
        ON f.DRG_Code = drg.DRG_Code
    GROUP BY
        drg.DRG_Code,
        drg.DRG_Name
)
SELECT
    *,
    CASE
        WHEN Total_Revenue >=
             (SELECT AVG(Total_Revenue) FROM DRG_Performance)
         AND Mortality_Rate >=
             (SELECT AVG(Mortality_Rate) FROM DRG_Performance)
        THEN 'High Revenue / High Mortality'
        ELSE 'Other'
    END AS Performance_Category
FROM DRG_Performance
ORDER BY
    Mortality_Rate DESC,
    Total_Revenue DESC; -- 563 rows

-- or
WITH DRG_Performance AS
(
    SELECT
        drg.DRG_Code,
        drg.DRG_Name,
        COUNT(*) AS Total_Cases,
        SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue,
        SUM(CASE WHEN f.Is_Dead = 'YES' THEN 1 ELSE 0 END) AS Deaths,
        CAST(SUM(CASE WHEN f.Is_Dead = 'YES' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS Mortality_Rate
    FROM Fact_Hospitalization f
    INNER JOIN Dim_DRG drg
        ON f.DRG_Code = drg.DRG_Code
    GROUP BY
        drg.DRG_Code,
        drg.DRG_Name
    HAVING COUNT(*) >= 100
)
SELECT
    DRG_Code,
    DRG_Name,
    Total_Cases,
    Total_Revenue,
    Deaths,
    Mortality_Rate
FROM DRG_Performance;

/*
Business value:
This identifies areas where financial importance and clinical risk intersect.
*/




/*
9. What percentage of gross revenue is being lost through discounts?
or, What percentage of gross amount is represented by discounts?
How much revenue is being reduced through patient discounts, and what is the effective discount rate?
*/
SELECT
    SUM(CAST(G_Amount AS DECIMAL(18,2))) AS Total_Gross_Amount,
    SUM(CAST(D_Amt AS DECIMAL(18,2))) AS Total_Discount,
    SUM(CAST(Net_Amount AS DECIMAL(18,2))) AS Total_Net_Revenue,
    CAST(
        SUM(CAST(D_Amt AS DECIMAL(18,2))) * 100.0
        / NULLIF(SUM(CAST(G_Amount AS DECIMAL(18,2))), 0)
        AS DECIMAL(10,2)
    ) AS Effective_Discount_Percentag
FROM Fact_Hospitalization; -- 1 row

-- or
SELECT
    SUM(CAST(G_Amount AS DECIMAL(18,2))) AS Total_Gross_Amount,
    SUM(CAST(D_Amt AS DECIMAL(18,2))) AS Total_Discount,
    SUM(CAST(Net_Amount AS DECIMAL(18,2))) AS Total_Net_Revenue,
    CAST(SUM(CAST(D_Amt AS DECIMAL(18,2))) * 100.0 / NULLIF(SUM(CAST(G_Amount AS DECIMAL(18,2))), 0) AS DECIMAL(10,2)
    ) AS Effective_Discount_Percentage
FROM Fact_Hospitalization;

/*
Business value:
Supports discount-policy evaluation, revenue optimization and financial reporting.
*/


-- confirm data-type of column
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    NUMERIC_PRECISION,
    NUMERIC_SCALE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Fact_Hospitalization'
  AND COLUMN_NAME IN (
      'G_Amount',
      'D_Amt',
      'Net_Amount'
  );




/*
10. Which district–DRG combinations have the highest hospitalization demand?
Which combinations of geographic district and treatment category generate the highest hospitalization volume?
*/
WITH DistrictDRG AS
(
    SELECT
        d.District_Name,
        drg.DRG_Name,
        COUNT(*) AS Total_Hospitalizations,
        SUM(f.Net_Amount) AS Total_Revenue
    FROM Fact_Hospitalization f
    INNER JOIN Dim_District d
        ON f.District_Code_ID = d.District_Code_ID
    INNER JOIN Dim_DRG drg
        ON f.DRG_Code = drg.DRG_Code
    GROUP BY
        d.District_Name,
        drg.DRG_Name
)

SELECT
    ROW_NUMBER() OVER (
        ORDER BY Total_Hospitalizations DESC
    ) AS Demand_Rank,
    District_Name,
    DRG_Name,
    Total_Hospitalizations,
    Total_Revenue
FROM DistrictDRG
ORDER BY Demand_Rank; -- 18,182 rows

-- or
SELECT TOP 10
    d.District_Name,
    drg.DRG_Name,
    COUNT(*) AS Total_Hospitalizations,
    SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue
FROM Fact_Hospitalization f
INNER JOIN Dim_District d
    ON f.District_Code_ID = d.District_Code_ID
INNER JOIN Dim_DRG drg
    ON f.DRG_Code = drg.DRG_Code
GROUP BY
    d.District_Name,
    drg.DRG_Name
ORDER BY
    Total_Hospitalizations DESC;

-- or
SELECT TOP 10
    CONCAT(d.District_Name, ' — ', drg.DRG_Name) AS District_DRG,
    d.District_Name,
    drg.DRG_Name,
    COUNT(*) AS Total_Hospitalizations,
    SUM(CAST(f.Net_Amount AS DECIMAL(18,2))) AS Total_Revenue
FROM Fact_Hospitalization f
INNER JOIN Dim_District d
    ON f.District_Code_ID = d.District_Code_ID
INNER JOIN Dim_DRG drg
    ON f.DRG_Code = drg.DRG_Code
GROUP BY
    d.District_Name,
    drg.DRG_Name
ORDER BY
    Total_Hospitalizations DESC;

/*
Business value:
Management can identify where specific treatments have the highest demand, 
which can support specialist allocation and regional service planning.
*/


