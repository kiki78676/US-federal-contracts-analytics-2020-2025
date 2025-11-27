--THIS IS WHAT I TRIED TO DO WITHOUT USING SQL QUERIES AND GETTING INSIGHTS DIRECTLY FROM POWER BI BUILDING RELATIONSHIPS

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
    awarding_sub_agency_name
INTO dbo.Dim_Agency
FROM dbo.Fact_FederalContracts_Clean;

ALTER TABLE dbo.Dim_Agency
ADD AgencyKey INT IDENTITY(1,1) PRIMARY KEY;


SELECT *
FROM dbo.Dim_Agency

--Create Dim_Recipient with DISTINCT

IF OBJECT_ID('dbo.Dim_Recipient') IS NOT NULL
    DROP TABLE dbo.Dim_Recipient;
GO

SELECT DISTINCT
    COALESCE(recipient_name, 'Unknown') AS recipient_name,
    COALESCE(recipient_state_code, 'Unknown') AS recipient_state_code,
    COALESCE(primary_place_of_performance_country_name, 'Unknown') AS recipient_country_name
INTO dbo.Dim_Recipient
FROM dbo.Fact_FederalContracts_Clean
WHERE recipient_name IS NOT NULL;

ALTER TABLE dbo.Dim_Recipient
ADD RecipientKey INT IDENTITY(1,1) PRIMARY KEY;



--Create Dim_PerformanceLocation from the fact table

IF OBJECT_ID('dbo.Dim_PerformanceLocation') IS NOT NULL
    DROP TABLE dbo.Dim_PerformanceLocation;
GO

SELECT DISTINCT
    COALESCE(primary_place_of_performance_state_code, 'Unknown') AS performance_state_code,
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
FROM dbo.Fact_FederalContracts_Clean
WHERE naics_code IS NOT NULL;

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