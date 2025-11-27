## US Federal Contracts Analytics (2020–2025)
# A Complete End-to-End Data Engineering + Analytics Project

This project analyzes U.S. federal contract spending from FY 2020–2025 using SQL, Python, and Power BI to uncover trends, vendor risk, agency spending behavior, and geographic distribution.

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

**Python ETL:** Automated download + load of Prime Transaction CSVs into SQL  
**SQL Server Modeling:** Fact cleaning, dimensional modeling, aggregated views  

**Business Logic:**  
- Year-over-Year (YoY) Growth  
- Vendor Market Share + HHI Concentration  
- Agency-Level Spending KPIs  
- Award Size Category Classification  
- State-Level Spending  
- NAICS Category Analysis  

**Power BI Dashboards:** Multi-page, interactive, enterprise-style visuals

---

## 🐍 Python Automation (ETL)

Includes:

- Automatic CSV ingestion  
- Schema validation  
- Data type enforcement  
- Null value handling  
- Bulk loading into SQL Server  
- Reusable ETL pipeline  

Folder: `python/ETL PROCESS.ipynb`

---

## 🧼 SQL Data Cleaning & Modeling

Built inside SQL Server:

- Cleaned fact table: `Fact_FederalContracts_Clean`  
- Multiple dimensions (Agency, Recipient, NAICS, PSC, Location)  
- Performance-optimized analytical views  

---

## 📊 Power BI Dashboards

### **1️⃣ Federal Spending Overview**
- Total obligations by fiscal year  
- Top spending agencies  
- Award distribution by category  
- Agency award count donut  

### **2️⃣ Vendor Market Concentration**
- Vendor HHI concentration score  
- Top vendors by spending  
- Market share donut chart  
- Concentration tables  

### **3️⃣ YoY Growth Analysis**
- YoY percentage change  
- Trend line  
- Size category distribution  
- Category-level award counts  

### **4️⃣ Geographic & NAICS Insights**
- Map of federal spending by state  
- Top NAICS categories  
- Treemap + bar chart  
- Metrics cards (vendors, sub-agencies, regions)
  
[https://app.powerbi.com/links/ulYq5EaC6D?ctid=70de1992-07c6-480f-a318-a1afcba03983&pbi_source=linkShare](https://app.powerbi.com/view?r=eyJrIjoiNDA3ZDZhYjAtMmZiMC00OTIyLWJiMmMtNTU5ZmFjNDViMTY2IiwidCI6IjcwZGUxOTkyLTA3YzYtNDgwZi1hMzE4LWExYWZjYmEwMzk4MyIsImMiOjN9)

---

## 📁 Repository Structure

```
/SQL
   Cleaning + Modeling Scripts
/python
   ETL PROCESS.ipynb
/powerbi
   Federal Contracts Dashboard.pbix
/Files
   (Git LFS recommended for large CSVs)
README.md
```

---

## 🚀 Key Insights Discovered

- Total federal obligations exceeded **$50.9B** (2020–2025)  
- FAA alone spent **$30B+**, dominating all agencies  
- Market is **highly competitive** (HHI < 1,000)  
- Most awards fall in **0–100k** category  
- Engineering Services (NAICS) leads with **$8B+**  
- TX, VA, and CA show strongest federal spending  

---

## 🧑‍💼 Why This Project Matters

This project reflects real analytics used in:

- Federal consulting  
- Enterprise procurement teams  
- Data engineering groups  
- Market concentration analysis  
- Vendor risk modeling  

It demonstrates full-stack capability:  
**Python → SQL → BI → Documentation**

---

## 📬 Contact

Created by **kiki78676**  
Feel free to connect or reach out for collaboration!

