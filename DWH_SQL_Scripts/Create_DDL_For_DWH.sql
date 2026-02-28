-- ============================================================
-- Data Warehouse DDL - Northwind Star Schema (SCD Type 2)
-- ============================================================

-- 1. Create Schemas with correct syntax
CREATE SCHEMA IF NOT EXISTS Fact;
CREATE SCHEMA IF NOT EXISTS Dim;
CREATE SCHEMA IF NOT EXISTS Stg;
CREATE SCHEMA IF NOT EXISTS Bridge;

-- 2. Drop tables with semicolons
DROP TABLE IF EXISTS Fact.Fact_sales;
DROP TABLE IF EXISTS Bridge.Employee_Territory;
DROP TABLE IF EXISTS Dim.dim_employee CASCADE;
DROP TABLE IF EXISTS Dim.Dim_category CASCADE;
DROP TABLE IF EXISTS Dim.Dim_Shipper CASCADE;
DROP TABLE IF EXISTS Dim.Dim_customer CASCADE;
DROP TABLE IF EXISTS Dim.Dim_Territory CASCADE;
DROP TABLE IF EXISTS Dim.Dim_Date CASCADE;
DROP TABLE IF EXISTS Dim.Dim_Product CASCADE;

-- 3. Create Tables
CREATE TABLE Dim.Dim_Date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL,
    day_name VARCHAR(15),
    month_name VARCHAR(15),
    quarter INT,
    year INT,
    is_weekend BOOLEAN,
    CONSTRAINT uk_full_date UNIQUE (full_date)
);

CREATE TABLE Dim.Dim_Product (
    product_key BIGSERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2),
    reorder_level INT,
    discontinued BOOLEAN,
    units_in_stock INT,    
    units_on_order INT,
    category_name VARCHAR(50),
    category_description TEXT,
    supplier_name VARCHAR(100),
    supplier_phone VARCHAR(50),
    supplier_state_name VARCHAR(100), 
    start_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    end_date TIMESTAMP,
    is_current BOOLEAN DEFAULT TRUE
);

CREATE TABLE Dim.Dim_Customer (
    customer_key BIGSERIAL PRIMARY KEY,
    customer_id CHAR(5) NOT NULL,
    company_name VARCHAR(100),
    contact_name VARCHAR(100),
    city VARCHAR(50),
    postal_code VARCHAR(50),
    country VARCHAR(50),
    region  VARCHAR(50),
    phone   VARCHAR(50),
    state_name VARCHAR(100), 
    state_abbr CHAR(50),     
    customer_type VARCHAR(50),
    customer_desc TEXT,
    is_current BOOLEAN DEFAULT TRUE
);

CREATE TABLE Dim.Dim_Employee (
    employee_key SERIAL PRIMARY KEY,
    employee_id INT NOT NULL UNIQUE,
    full_name VARCHAR(100),
    title VARCHAR(50),
    hire_date DATE,
    city VARCHAR(50),
    home_phone VARCHAR(25),
    reports_to INT,
    is_current BOOLEAN DEFAULT TRUE
);

CREATE TABLE Dim.Dim_Territory (
    territory_key SERIAL PRIMARY KEY,
    territory_id VARCHAR(20) NOT NULL UNIQUE,
    territory_description VARCHAR(100),
    region_description VARCHAR(100)
);

CREATE TABLE Dim.Dim_Shipper (
    shipper_key BIGSERIAL PRIMARY KEY,
    shipper_id INT NOT NULL,
    company_name VARCHAR(100),
    phone VARCHAR(50)
);

CREATE TABLE Fact.Fact_Sales (
    sales_key BIGSERIAL PRIMARY KEY,
    product_key BIGINT REFERENCES Dim.Dim_Product(product_key),
    customer_key BIGINT REFERENCES Dim.Dim_Customer(customer_key),
    employee_key INT REFERENCES Dim.Dim_Employee(employee_key),
    shipper_key BIGINT REFERENCES Dim.Dim_Shipper(shipper_key),
    date_key INT REFERENCES Dim.Dim_Date(date_key),
    
    order_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price_sold DECIMAL(10,2) NOT NULL, 
    discount DECIMAL(10,2) DEFAULT 0,
    freight DECIMAL(10,2),
    total_amount DECIMAL(10,2) GENERATED ALWAYS AS (quantity * unit_price_sold * (1 - discount)) STORED
);

CREATE TABLE Bridge.Employee_Territory(
    employee_key INT REFERENCES Dim.Dim_Employee(employee_key),
    territory_key INT REFERENCES Dim.Dim_Territory(territory_key),
    PRIMARY KEY (employee_key, territory_key)
);