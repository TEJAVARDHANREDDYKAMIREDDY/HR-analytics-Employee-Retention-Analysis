/*
	PROJECT NAME : P1400 HR Analytics
    DATASETS : HR_1 & HR_2
    GROUP : GROUP 01
*/

CREATE database HRanalytics1;

use HRanalytics1;

-- CREATE TABLES

-- HR1 TABLE

CREATE TABLE HR1 (
    Age INT,
    Attrition VARCHAR(20),
    BusinessTravel VARCHAR(255),
    DailyRate INT,
    Department VARCHAR(255),
    DistanceFromHome INT,
    Education INT,
    EducationField VARCHAR(255),
    EmployeeCount INT,
    EmployeeNumber INT PRIMARY KEY,  -- because it contains unique custome id
    EnvironmentSatisfaction INT,
    Gender VARCHAR(50),
    HourlyRate INT,
    JobInvolvement INT,
    JobLevel INT,
    JobRole VARCHAR(255),
    JobSatisfaction INT,
    MaritalStatus VARCHAR(100)
);

SELECT * FROM HR1;

-- HR2 TABLE

CREATE TABLE HR2 (
    EmployeeID INT PRIMARY KEY, -- because it contails unique values
    MonthlyIncome INT,
    MonthlyRate INT,
    NumCompaniesWorked INT,
    Over18 VARCHAR(5),
    OverTime VARCHAR(10),
    PercentSalaryHike INT,
    PerformanceRating INT,
    RelationshipSatisfaction INT,
    StandardHours INT,
    StockOptionLevel INT,
    TotalWorkingYears INT,
    TrainingTimesLastYear INT,
    WorkLifeBalance INT,
    YearsAtCompany INT,
    YearsInCurrentRole INT,
    YearsSinceLastPromotion INT,
    YearsWithCurrManager INT
);


SELECT * FROM HR2;

DESC HR2;

-- IMPORT DATA

-- IMPORTING TWO DATASETS USING LOCAL_INFILE

SHOW VARIABLES LIKE 'local_infile'; -- Currently showing OFF we have to turned ON
SET GLOBAL local_infile = 1; -- Turning ON Local Infile

-- BEFORE IMPORTING WE CONVERTED .xlsx FORMAT TO .csv FORMAT USING MS EXCEL

-- IMPORTING HR_1 DATASET

LOAD DATA LOCAL INFILE 'C:/Users/K TEJA VARDHAN REDDY/Downloads/HR_1/HR1DATA.CSV'
INTO TABLE HR1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM HR1;

-- IMPORTING HR_2 DATASET

LOAD DATA LOCAL INFILE 'C:/Users/K TEJA VARDHAN REDDY/Downloads/HR_2/HR2DATA.CSV'
INTO TABLE HR2
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

SELECT COUNT(*) FROM HR2;

-- JOINING BOTH TABLES USING INNER JOIN 

SELECT COUNT(*) AS Total_Rows 
FROM HR1 AS H1 INNER JOIN HR2 AS H2
ON H1.EmployeeNumber = H2.EmployeeID;

-- CREATE VIEW 

CREATE VIEW HRDATA AS
SELECT * 
FROM HR1 AS H1 INNER JOIN HR2 AS H2
ON H1.EmployeeNumber = H2.EmployeeID;

SELECT * FROM HRDATA;

USE HRANALYTICS1;



-- KPI VALUES --

-- 1. TOTAL EMPLOYEES

SELECT COUNT(distinct EmployeeNumber) as `Total Employees`
FROM HR1;

-- 2. TOTAL ATTRITION 

SELECT 
	COUNT(EmployeeNumber) `Total Attrition`
FROM HR1
where Attrition = "yes";

-- 3. ACTIVE EMPLOYEES

SELECT 
	COUNT(EmployeeNumber) as `Active employees`
FROM hr1
where Attrition = "no";

-- 4. ATTRITION RATE

SELECT 
	concat(
	ROUND(
		100*SUM(CASE WHEN Attrition = "Yes" THEN 1 ELSE 0 END) / count(distinct EmployeeNumber),
        2),
        "%") AS `Attrition Rate`
FROM HR1;

-- 5. AVERAGE MONTHLY INCOME

SELECT 
	ROUND(
		AVG(MonthlyIncome)
        ) AS `Avg Monthly Income`
FROM HR2;

-- 6. AVERAGE AGE

SELECT 
ROUND(
	AVG(Age)
	) AS `Avg Age`
FROM HR1;


-- 7. AVERAGE WORK LIFE BALANCE

SELECT
	CONCAT(ROUND(AVG(WorkLifeBalance),2), ' / 4') as `Avg Work Life Balance`
FROM HR2;

-- 8. EMPLOYEES AVERAGE WORKING YEARS

SELECT
	ROUND(
		AVG(TotalWorkingYears)
		) as `Avg Working Years`
FROM HR2;



-- CHARTS --

-- 1. Average Attrition rate for all Departments

SELECT 
	Department,
    concat(
    ROUND(
		100*AVG(CASE WHEN Attrition = "Yes" then 1 ELSE 0 END ),
    2),"%") AS Dep_Wise_Attrition_Rate
FROM HR1
GROUP BY Department
ORDER BY Dep_Wise_Attrition_Rate desc;


-- 2. Average Hourly rate of Male Research Scientist

SELECT 
	ROUND(
		AVG(HourlyRate)
        ,2)
FROM HR1
WHERE Gender = "Male" and JobRole = "Research Scientist";


-- 3. Attrition rate Vs Monthly income stats

SELECT 
    CASE
        WHEN MonthlyIncome < 10000 THEN 'Low Income (<10000)'
        WHEN MonthlyIncome < 20000 THEN 'Medium Income (<20000)'
        WHEN MonthlyIncome < 35000 THEN 'High Income (<35000)'
        ELSE 'Very High Income (35000+)'
    END AS Income_Group,

    CASE
        WHEN MonthlyIncome < 10000 THEN 1
        WHEN MonthlyIncome < 20000 THEN 2
        WHEN MonthlyIncome < 35000 THEN 3
        ELSE 4
    END AS SortIncomegroup,
	concat(
    ROUND(
        100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(distinct EmployeeNumber),
    2),"%") AS Attrition_Rate
FROM hrdata
GROUP BY Income_Group, SortIncomegroup
ORDER BY SortIncomegroup;


-- 4. Average working years for each Department
SELECT
	Department,
    ROUND(
		AVG(Totalworkingyears),
        2) AS `avg working years`
FROM hrdata
GROUP BY Department
order by `avg working years` DESC;


-- 5. Job Role Vs Work life balance

SELECT 
	Jobrole,
	ROUND(
		AVG(Worklifebalance),
        3) AS `Avg worklife balance`
FROM hrdata
GROUP BY Jobrole
order by `Avg worklife balance` DESC;


-- 6. Attrition rate Vs Year since last promotion relation

WITH PromotionYears AS (
	SELECT
		*,
		CASE		WHEN YearsSinceLastPromotion < 2 THEN "0-2 Years"
			WHEN YearsSinceLastPromotion < 5 THEN "3-5 Years"
			WHEN YearsSinceLastPromotion < 10 THEN "6-10 Years"
			WHEN YearsSinceLastPromotion < 15 THEN "11-15 Years"
			WHEN YearsSinceLastPromotion < 20 THEN "16-20 Years"
			WHEN YearsSinceLastPromotion < 25 THEN "21-25 Years"
			WHEN YearsSinceLastPromotion < 30 THEN "26-30 Years"
			ELSE "30+ Years"
	
		END as "PromotionGroup",
		CASE
			WHEN YearsSinceLastPromotion < 2 THEN 1
			WHEN YearsSinceLastPromotion < 5 THEN 2
			WHEN YearsSinceLastPromotion < 10 THEN 3
			WHEN YearsSinceLastPromotion < 15 THEN 4
			WHEN YearsSinceLastPromotion < 20 THEN 5
			WHEN YearsSinceLastPromotion < 25 THEN 6
			WHEN YearsSinceLastPromotion < 30 THEN 7
			ELSE 8
		END as "SortPromotionGroup"
	FROM HRdata
)
SELECT
	PromotionGroup as `Promotion Years Group`,
    ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT EmployeeNumber), 2) as `Attrition Rate`
FROM PromotionYears
GROUP BY PromotionGroup, SortPromotionGroup
ORDER BY SortPromotionGroup ASC;



-- 7. ATTRITION RATE BY AGE
WITH AgeAttrition AS (
	SELECT
		*,
		CASE
			WHEN Age <= 25 THEN "18-25"
			WHEN Age <= 35 THEN "26-35"
			WHEN Age <= 45 THEN "36-45"
			WHEN Age <= 55 THEN "46-55"
			ELSE "55+"
		END as "AgeGroup"
	FROM HR1
)
SELECT
	AgeGroup as `Age Group`,
	concat(ROUND(100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT EmployeeNumber), 2),"%") as `Attrition Rate`
FROM AgeAttrition
GROUP BY AgeGroup
ORDER BY `Attrition Rate` DESC;

 -- 8. AVERAGE ATTRITION RATE BY JOB ROLE
SELECT
	JobRole,
    concat(
    ROUND(
		100 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(DISTINCT EmployeeNumber),
	2),"%") as `Avg Attrition Rate`
FROM HR1
GROUP BY JobRole
ORDER BY `Avg Attrition Rate` DESC; 
