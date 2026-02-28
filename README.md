# Northwind End-to-End Data Warehouse & ETL Project

## Project Overview
This project demonstrates a complete Data Engineering lifecycle, transforming raw operational data from the **Northwind** database into a structured **Data Warehouse (DWH)**. The solution leverages **SSIS** for orchestration and **PostgreSQL** for robust data storage and transformation.

---

## Architecture & Design

### 1. Data Warehouse Schema (Star Schema)
The core of the project is a professional **Star Schema** designed for optimal analytical performance.
* **Fact Table:** `fact_sales` at the **Atomic Grain** (Order Detail Level).
* **Dimensions:** `Dim_Product`, `Dim_Employee`, `Dim_Customer`, `Dim_Shipper`, and `Dim_Date`.
* **Slowly Changing Dimensions (SCD Type 2):** Implemented on dimensions like Products to track historical changes over time.
* **Many-to-Many Relationship:** Handled via a **Bridge Table** (`Employee_Territory`) to accurately link employees with multiple regions.

![DWH Star Schema Design](https://github.com/YoussefHamedddd/Northwind-DWH-ETL-Pipeline-SSIS-PostgreSQL/blob/main/docs/DWH%20Schema.png?raw=true)

---

## ETL Process (SSIS Orchestration)

The ETL pipeline is divided into two main phases to ensure data isolation and system stability.

### Phase 1: Staging & Isolation
In this phase, data is extracted from the operational source and loaded into a **Staging Layer**. This ensures that complex ETL logic doesn't impact the performance of the production database.

![SSIS Staging Workflow](https://github.com/YoussefHamedddd/Northwind-DWH-ETL-Pipeline-SSIS-PostgreSQL/blob/main/docs/Create%20Staging%20Tables%20and%20Load%20Data.png?raw=true)

### Phase 2: DWH Transformation & Loading
Data is transformed and loaded into the Star Schema. I utilized **Push-down Optimization** by executing **Stored Procedures** in PostgreSQL, allowing the database engine to handle heavy transformations efficiently.

![SSIS DWH Loading Workflow](https://github.com/YoussefHamedddd/Northwind-DWH-ETL-Pipeline-SSIS-PostgreSQL/blob/main/docs/Create%20DWH%20Tables%20and%20Load%20Data.png?raw=true)

---

## Data Validation & Testing
To ensure the integrity of the Data Warehouse, I performed several SQL validation tests.

**Example: Validating Many-to-Many Bridge Table**
This test confirms that the Bridge Table correctly maps multiple territories to single employees without inflating row counts.

```sql
/* SQL Validation: Checking Many-to-Many via Bridge Table */
SELECT 
    e.full_name, 
    COUNT(bri.territory_key) AS territories_count
FROM Dim.Dim_Employee e
LEFT JOIN Bridge.Employee_Territory bri ON e.employee_key = bri.employee_key
GROUP BY e.employee_key, e.full_name
ORDER BY territories_count DESC;
