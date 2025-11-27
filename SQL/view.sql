-- creating views for each query so I can turn meaningful insights on POWER BI
USE federal_spending_db

--Total Spending by Fiscal Year

CREATE VIEW vw_TotalSpending_ByFiscalYear AS
SELECT 
    action_date_fiscal_year,
    SUM(federal_action_obligation) AS total_spending
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY action_date_fiscal_year;

--Top Spending Agencies

CREATE VIEW vw_TopAgencies_Spending AS
SELECT 
    awarding_sub_agency_name,
    SUM(federal_action_obligation) AS total_spending
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY awarding_sub_agency_name;

--Top Vendors (Top 10)

CREATE VIEW vw_TopVendors AS
SELECT TOP 10
    recipient_name,
    SUM(federal_action_obligation) AS total_received_money
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY recipient_name
ORDER BY SUM(federal_action_obligation) DESC;

--Award Size Categories

CREATE VIEW vw_AwardSize_Categories AS
WITH category AS (
    SELECT
        *,
        CASE    
            WHEN federal_action_obligation < 0 THEN '0 or Negative'
            WHEN federal_action_obligation <= 10000 THEN 'Low Agency 0-10k'
            WHEN federal_action_obligation <= 100000 THEN 'Growing Agency 10k-100k'
            WHEN federal_action_obligation <= 1000000 THEN 'Good Agency 100k-1M'
            WHEN federal_action_obligation <= 50000000 THEN 'Big Agency 1M-50M'
            ELSE 'Large Cap Agency 50M +'
        END AS Category
    FROM dbo.Fact_FederalContracts_Clean
)
SELECT 
    Category,
    COUNT(*) AS TransactionCount,
    SUM(federal_action_obligation) AS totalObligations
FROM category
GROUP BY Category;

--Awards per Sub Agency

CREATE VIEW vw_Awards_PerSubAgency AS
SELECT
    awarding_sub_agency_name,
    COUNT(*) AS TransactionCount
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY awarding_sub_agency_name;

--Awards per Sub Agency per Year

CREATE VIEW vw_Awards_PerSubAgency_Year AS
SELECT
    action_date_fiscal_year,
    awarding_sub_agency_name,
    COUNT(*) AS TransactionCount
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY action_date_fiscal_year, awarding_sub_agency_name;


--Unique Vendors Overall

CREATE VIEW vw_UniqueVendors_Overall AS
SELECT
    COUNT(DISTINCT recipient_name) AS UniqueVendors
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0;

--Unique Vendors per Agency

CREATE VIEW vw_Vendors_PerAgency AS
SELECT 
    awarding_sub_agency_name,
    COUNT(DISTINCT recipient_name) AS UniqueVendors
FROM dbo.Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY awarding_sub_agency_name;

--YoY Spending View (FULL)

CREATE VIEW vw_YoY_Spending AS
WITH yearly_spending AS (
    SELECT 
        action_date_fiscal_year,
        awarding_sub_agency_name,
        SUM(federal_action_obligation) AS total_spending
    FROM dbo.Fact_FederalContracts_Clean
    WHERE federal_action_obligation > 0
    GROUP BY action_date_fiscal_year, awarding_sub_agency_name
),
with_prev AS (
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
)
SELECT *
FROM yoy_calc;


--HHI Market Concentration (Vendors)

CREATE VIEW vw_HHI_Vendors AS
WITH vendor AS (
    SELECT 
        recipient_name,
        SUM(federal_action_obligation) AS vendor_spending
    FROM dbo.Fact_FederalContracts_Clean
    WHERE federal_action_obligation > 0
    GROUP BY recipient_name
), 
total AS (
    SELECT 
        SUM(vendor_spending) AS total_spending_market
    FROM vendor
),
HHI_final AS (
    SELECT 
        v.recipient_name,
        v.vendor_spending,
        t.total_spending_market,
        (v.vendor_spending / t.total_spending_market) * 100 AS Share,
        POWER((v.vendor_spending / t.total_spending_market) * 100, 2) AS each_HHI
    FROM vendor v
    CROSS JOIN total t
)
SELECT *
FROM HHI_final;

--HHI Market Concentration by Sub Agency

CREATE VIEW vw_HHI_Agency AS
WITH agency AS (
    SELECT 
        awarding_sub_agency_name,
        SUM(federal_action_obligation) AS agency_spending
    FROM dbo.Fact_FederalContracts_Clean
    WHERE federal_action_obligation > 0
    GROUP BY awarding_sub_agency_name
), 
total AS (
    SELECT 
        SUM(agency_spending) AS total_spending_market
    FROM agency
),
HHI_final AS (
    SELECT 
        v.awarding_sub_agency_name,
        v.agency_spending,
        t.total_spending_market,
        (v.agency_spending / t.total_spending_market) * 100 AS Share,
        POWER((v.agency_spending / t.total_spending_market) * 100, 2) AS each_HHI
    FROM agency v
    CROSS JOIN total t
)
SELECT *
FROM HHI_final;

--PSC Spending

CREATE VIEW vw_PSC_Spending AS
SELECT 
    product_or_service_code_description AS psc_desc,
    SUM(federal_action_obligation) AS total_spending
FROM Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY product_or_service_code_description;

--Spending Concentration by Sector (NAICS)

CREATE VIEW vw_NAICS_Spending AS
SELECT 
    naics_description,
    SUM(federal_action_obligation) AS total_spending
FROM Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
GROUP BY naics_description;

----Spending Concentration by State
DROP VIEW vw_State_Spending;
GO

CREATE VIEW vw_State_Spending AS
SELECT 
    primary_place_of_performance_state_code,
    primary_place_of_performance_country_name,
    SUM(federal_action_obligation) AS total_spending
FROM Fact_FederalContracts_Clean
WHERE federal_action_obligation > 0
AND primary_place_of_performance_country_name = 'UNITED STATES'
GROUP BY primary_place_of_performance_state_code,primary_place_of_performance_country_name

SELECT * FROM vw_State_Spending

