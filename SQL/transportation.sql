SELECT count (*) FROM PrimeTransactions_2020_2025;

--STEP 1: Check row count and column count

SELECT COUNT(*) AS Total_Rows
FROM PrimeTransactions_2020_2025;


SELECT COUNT(*) AS Total_Columns
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PrimeTransactions_2020_2025';

--STEP 2: View sample rows

SELECT TOP 50 *
FROM PrimeTransactions_2020_2025;

--STEP 3: Check fiscal years present

SELECT action_date_fiscal_year,
count(*) AS total_records
FROM dbo.primeTransactions_2020_2025
GROUP BY action_date_fiscal_year
ORDER BY action_date_fiscal_year DESC

-- STEP 3: Check fiscal years present

SELECT
    MIN(federal_action_obligation) AS MinObligation,
    MAX(federal_action_obligation) AS MaxObligation,
    AVG(federal_action_obligation) AS AvgObligation
FROM dbo.PrimeTransactions_2020_2025;


SELECT federal_action_obligation
FROM PrimeTransactions_2020_2025
WHERE federal_action_obligation < 0;

SELECT COUNT(*) AS NegativeObligations
FROM PrimeTransactions_2020_2025
WHERE federal_action_obligation < 0;

-- CREATE A CLEAN TABLE HANDLING NO NULL AWARD ID AND TAGS NEGATIVE VALUE AS 'Deobligation'

USE federal_spending_db;
GO

DROP TABLE IF EXISTS Fact_FederalContracts_Clean;

SELECT
    contract_transaction_unique_key,
    contract_award_unique_key,
    award_id_piid,
    action_date,
    action_date_fiscal_year,
    awarding_agency_name,
    awarding_sub_agency_name,
    awarding_office_name,
    recipient_name,
    recipient_state_code,
    naics_code,
    naics_description,
    product_or_service_code,
    product_or_service_code_description,
    federal_action_obligation,
     CASE 
        WHEN federal_action_obligation < 0 THEN 'Deobligation' 
        ELSE 'Obligation' 
    END AS obligation_type,
    current_total_value_of_award,
    base_and_all_options_value,
    potential_total_value_of_award,
    primary_place_of_performance_state_code,
    primary_place_of_performance_country_name
INTO Fact_FederalContracts_Clean
FROM PrimeTransactions_2020_2025
WHERE award_id_piid IS NOT NULL;

--READING THE CLEAN TABLE
SELECT * FROM Fact_FederalContracts_Clean;

---“What is total spending by fiscal year?”

SELECT 
action_date_fiscal_year,
sum(federal_action_obligation) as total_spending
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY action_date_fiscal_year
ORDER BY action_date_fiscal_year DESC


--“Which agencies spend the most money?”

SELECT awarding_sub_agency_name,
sum(federal_action_obligation) as total_spending
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY awarding_sub_agency_name
ORDER BY sum(federal_action_obligation) DESC

--“Which vendors (recipients) receive the most money?”

SELECT TOP 10
recipient_name,
sum(federal_action_obligation) as total_received_money
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY recipient_name
ORDER BY sum(federal_action_obligation) DESC

---Award Size Distribution (Buckets)

;WITH category AS (
SELECT
*,
CASE    
    WHEN federal_action_obligation < 0 THEN '0 or Negative'
    WHEN federal_action_obligation > 0  AND federal_action_obligation <= 10000 THEN 'Low Agency 0-10k'
    WHEN federal_action_obligation > 10000  AND federal_action_obligation <= 100000 THEN 'Growing Agency 10k-100k'
    WHEN federal_action_obligation > 100000  AND federal_action_obligation <= 1000000 THEN 'Good Agency 100k-1M'
    WHEN federal_action_obligation > 1000000  AND federal_action_obligation <= 50000000 THEN 'Big Agency 1M-50M'
    ELSE 'Large Cap Agency 50M +'
END AS Category
FROM dbo.Fact_FederalContracts_Clean
)
SELECT 
Category,
count(*) AS TransactionCount,
sum(federal_action_obligation) as totalObligations
FROM Category
GROUP BY Category
ORDER BY sum(federal_action_obligation) DESC

--Number of Awards per Sub Agency

SELECT
    awarding_sub_agency_name,
    COUNT(*) AS TransactionCount
FROM Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY awarding_sub_agency_name
ORDER BY TransactionCount DESC;


--Number of Awards per Sub Agency per year

SELECT
    action_date_fiscal_year,
    awarding_sub_agency_name,
    COUNT(*) AS TransactionCount
FROM Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY action_date_fiscal_year,
    awarding_sub_agency_name
ORDER BY  action_date_fiscal_year,TransactionCount DESC;

--Number of Unique Vendors (Overall)

SELECT
    COUNT(DISTINCT recipient_name) AS UniqueVendors
FROM Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0;

--Number of Vendors per Agency

SELECT 
    awarding_sub_agency_name,
    COUNT(DISTINCT recipient_name) as UniqueVendors
FROM Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY awarding_sub_agency_name
ORDER BY COUNT(DISTINCT recipient_name) DESC

--Agency Spending by Fiscal Year (for YoY Analysis for last 3 years)

;WITH yearly_spending AS (
    -- 1) Aggregate by year + sub-agency
    SELECT 
        action_date_fiscal_year,
        awarding_sub_agency_name,
        SUM(federal_action_obligation) AS total_spending
    FROM dbo.Fact_FederalContracts_Clean
    WHERE federal_action_obligation > 0
    GROUP BY action_date_fiscal_year, awarding_sub_agency_name
),
with_prev AS (
    -- 2) Use LAG on the aggregated numbers
    SELECT
        action_date_fiscal_year,
        awarding_sub_agency_name,
        total_spending,
        LAG(total_spending, 1) OVER (
            PARTITION BY awarding_sub_agency_name
            ORDER BY action_date_fiscal_year
        ) AS prev_year_spending
    FROM yearly_spending
),
yoy_calc AS (
    -- 3) Calculate YoY difference and % growth
    SELECT
        action_date_fiscal_year,
        awarding_sub_agency_name,
        total_spending,
        prev_year_spending,
        CASE 
            WHEN prev_year_spending IS NULL THEN NULL
            ELSE total_spending - prev_year_spending
        END AS YoY_difference,
        CASE
            WHEN prev_year_spending IS NULL OR prev_year_spending = 0 THEN NULL
            ELSE (total_spending - prev_year_spending) * 100.0 / prev_year_spending
        END AS YoY_percentage_growth
    FROM with_prev
),
ranked AS (
    -- 4) Keep only the latest year per sub-agency
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY awarding_sub_agency_name
            ORDER BY action_date_fiscal_year DESC
        ) AS rn
    FROM yoy_calc
)
SELECT
    action_date_fiscal_year AS current_year,
    action_date_fiscal_year - 1 AS last_year,  -- simple label
    awarding_sub_agency_name,
    total_spending,
    prev_year_spending,
    YoY_difference,
    YoY_percentage_growth
FROM ranked
WHERE rn IN (1,2,3)               -- latest 3 years only
ORDER BY total_spending DESC;

--- CLEANING
SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE awarding_agency_name IS NULL


SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE awarding_sub_agency_name IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE recipient_name IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE recipient_state_code IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE naics_code IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE product_or_service_code IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE contract_transaction_unique_key IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE contract_award_unique_key IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE award_id_piid IS NULL

SELECT 
count(*)
FROM dbo.Fact_FederalContracts_Clean
WHERE awarding_office_name IS NULL

SELECT *
FROM dbo.Fact_FederalContracts_Clean

SELECT COUNT(*) - COUNT(DISTINCT contract_transaction_unique_key)
AS NumDuplicates
FROM Fact_FederalContracts_Clean;

--- create Dim_agency using simple distinct
IF OBJECT_ID('dbo.Dim_Agency') IS NOT NULL
    DROP TABLE dbo.Dim_Agency;
GO

-- Create Dim_Agency using DISTINCT values
SELECT DISTINCT
    awarding_agency_name,
    awarding_sub_agency_name,
    awarding_office_name
INTO dbo.Dim_Agency
FROM dbo.Fact_FederalContracts_Clean;

ALTER TABLE dbo.Dim_Agency
ADD AgencyKey INT IDENTITY(1,1) PRIMARY KEY;


SELECT *
FROM dbo.Dim_Agency

--Create Dim_Recipient with DISTINCT

IF OBJECT_ID('dbo.Dim_Recipient') IS NOT NULL
    DROP TABLE dbo.Dim_Recipient
GO

SELECT DISTINCT
recipient_name,
    COALESCE(recipient_state_code, 'Unknown') AS recipient_state_code,
    COALESCE(primary_place_of_performance_country_name, 'Unknown') AS recipient_country_name
INTO dbo.Dim_Recipient
FROM dbo.Fact_FederalContracts_Clean;

ALTER TABLE dbo.Dim_Recipient
ADD RecipientKey INT IDENTITY(1,1) PRIMARY KEY;


--Create Dim_PerformanceLocation from the fact table

IF OBJECT_ID('dbo.Dim_PerformanceLocation') IS NOT NULL
    DROP TABLE dbo.Dim_PerformanceLocation;
GO

SELECT DISTINCT
    COALESCE(primary_place_of_performance_state_code, 'Unknown')  AS performance_state_code,
    COALESCE(primary_place_of_performance_country_name, 'Unknown') AS performance_country_name
INTO dbo.Dim_PerformanceLocation
FROM dbo.Fact_FederalContracts_Clean;

ALTER TABLE dbo.Dim_PerformanceLocation
ADD PerformanceLocationKey INT IDENTITY(1,1) PRIMARY KEY;

--Create Dim_NAICS

IF OBJECT_ID('dbo.Dim_NAICS') IS NOT NULL
    DROP TABLE dbo.Dim_NAICS;
GO

SELECT DISTINCT
    COALESCE(CAST(naics_code AS NVARCHAR(20)), 'Unknown') AS naics_code,
    COALESCE(naics_description, 'Unknown') AS naics_description
INTO dbo.Dim_NAICS
FROM dbo.Fact_FederalContracts_Clean;

ALTER TABLE dbo.Dim_NAICS
ADD NAICSKey INT IDENTITY(1,1) PRIMARY KEY;

SELECT * FROM dbo.Dim_NAICS

--Create Dim_PSC

IF OBJECT_ID('dbo.Dim_PSC') IS NOT NULL
    DROP TABLE dbo.Dim_PSC;
GO

SELECT DISTINCT
    COALESCE(CAST(product_or_service_code AS NVARCHAR(20)), 'Unknown') AS product_or_service_code,
    COALESCE(product_or_service_code_description, 'Unknown') AS psc_description
INTO dbo.Dim_PSC
FROM dbo.Fact_FederalContracts_Clean;

ALTER TABLE dbo.Dim_PSC
ADD PSCKey INT IDENTITY(1,1) PRIMARY KEY;


---I built an HHI market concentration model using SQL to measure vendor dependency risk.
---I calculated vendor-level spend shares,
---computed squared shares, aggregated to final HHI, and categorized the market as competitive. 
---This helps procurement teams evaluate supplier risk and negotiate pricing.

WITH vendor AS (
SELECT 
recipient_name,
sum(federal_action_obligation) AS vendor_spending
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY recipient_name
), 
total AS (
SELECT 
sum(vendor_spending) as total_spending_market
FROM vendor
),
HHI_final AS (
SELECT 
v.recipient_name,
v.vendor_spending,
t.total_spending_market,
(v.vendor_spending / t.total_spending_market) * 100 as Share,
POWER((v.vendor_spending / t.total_spending_market) * 100,2) as each_HHI
FROM vendor v
CROSS JOIN total t
),
market AS (
SELECT
SUM(each_HHI) as HHI
FROM HHI_final
)
SELECT
h.recipient_name,
h.vendor_spending,
h.Share,
m.HHI
FROM HHI_final h
CROSS JOIN market m

-- WITH SUBAGENCY
;WITH agency AS (
SELECT 
awarding_sub_agency_name,
sum(federal_action_obligation) AS agency_spending
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY awarding_sub_agency_name
), 
total AS (
SELECT 
sum(agency_spending) as total_spending_market
FROM agency
),
HHI_final AS (
SELECT 
v.awarding_sub_agency_name,
v.agency_spending,
t.total_spending_market,
(v.agency_spending / t.total_spending_market) * 100 as Share,
POWER((v.agency_spending / t.total_spending_market) * 100,2) as each_HHI
FROM agency v
CROSS JOIN total t
),
market AS (
SELECT
SUM(each_HHI) as HHI
FROM HHI_final
)
SELECT
h.awarding_sub_agency_name,
h.agency_spending,
h.Share,
m.HHI
FROM HHI_final h
CROSS JOIN market m