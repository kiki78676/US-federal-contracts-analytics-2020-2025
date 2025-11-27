# 🇺🇸 US Federal Contracts Analytics (2020–2025)
## A Complete End-to-End Data Engineering + Analytics Project

This project analyzes U.S. federal contract spending from FY 2020–2025 using SQL, Python, and Power BI to uncover trends, vendor risk, agency spending behavior, market concentration, and geographic distribution.

Dataset Source (USAspending.gov):  
🔗 https://www.usaspending.gov/

---

## 📦 Project Overview

This end-to-end project covers:

- Data Extraction & Automation using Python  
- Data Cleaning, Standardization & Modeling inside SQL Server  
- Creation of Analytical Views & Performance-Optimized Queries  
- Business Insights & Metrics (YoY growth, vendor concentration, award buckets, etc.)  
- Visualization & Storytelling in Power BI  
- GitHub Documentation for portfolio use  

The goal is to simulate real federal procurement analytics used in government, consulting, and enterprise data teams.

---

## 🧱 Project Architecture

- **Python ETL:** Automated download + load of Prime Transaction CSVs into SQL  
- **SQL Server Modeling:** Fact cleaning, dimensional modeling, aggregated views  
- **Business Logic:**  
  - Year-over-Year (YoY) Growth  
  - Vendor Market Share + HHI Concentration  
  - Agency-level spending KPIs  
  - Award Size Category Classification  
  - State-Level Spending  
  - NAICS Category Analysis  
- **Power BI Dashboards:** Interactive, multi-layer insights for agencies, vendors, industries, and geography

---

## 🐍 Python Automation (ETL)

Includes:

- Automatic CSV ingestion  
- Data type enforcement  
- Null value handling  
- Batch loading to SQL Server  
- Reusable ETL pipeline  

Folder: `python/ETL PROCESS.ipynb`

---

## 🧼 SQL Data Cleaning & Modeling

Built inside SQL Server:

- Cleaned fact table: `Fact_FederalContracts_Clean`
- Dimension modeling (recipient, NAICS, PSC, location, agency)
- Aggregated analytical views

Key SQL assets included:

- Award buckets  
- Agency YoY growth  
- Vendor market concentration (HHI)  
- State spending summaries  
- NAICS spending rankings  

Folder: `SQL/`

---

## 📊 Power BI Dashboards

The project includes **multiple report pages**, showcasing:

### **1️⃣ Federal Spending Overview**
- Total obligations by fiscal year  
- Top spending agencies  
- Award distribution by category  
- Total obligations card  
- Agency award count donut  

### **2️⃣ Vendor Market Concentration**
- HHI concentration score  
- Top 6 vendors  
- Vendor market share donut  
- Vendor ranking table  
- Sub-agency concentration  

### **3️⃣ YoY Growth Analysis**
- YoY breakdown table  
- Trend line of spending  
- Award size distribution  
- Obligations by size category  

### **4️⃣ Geographic & Industry Insights**
- Federal spending by U.S. state (map)
- NAICS top categories (bar + treemap)
- Total sub-agencies, vendor count, state count  

Folder: `powerbi/`

---

## 📁 Repository Structure


---

## 🚀 Key Insights Discovered

- Federal spending grew steadily from **2020 to 2025**, surpassing **$50B total**  
- FAA dominates spending with over **$30B**  
- Vendor market is **highly competitive** — HHI below 1,000  
- Award sizes are mostly small: **0–100k range has 80k+ awards**  
- NAICS "Engineering Services" leads with **over $8B spending**  
- Texas, Virginia, and California show highest state spending  

---

## 🧑‍💼 Why This Project Matters

This project mirrors REAL analytics work done in:

- Federal consulting firms  
- Data engineering teams  
- Public sector analytics  
- Enterprise procurement intelligence  
- Market concentration & risk assessment  

It demonstrates full-stack capability:

**Python → SQL → BI → Documentation.**

---

## 📬 Contact

Created by **kiki78676**  
If you’d like help understanding or replicating this project, feel free to connect!
