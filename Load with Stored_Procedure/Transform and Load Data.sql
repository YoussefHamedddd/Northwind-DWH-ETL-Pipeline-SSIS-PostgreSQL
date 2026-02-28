CREATE OR REPLACE PROCEDURE Dim.Load_Dim_Product()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear the existing data in the dimension table
    TRUNCATE TABLE Dim.Dim_Product RESTART IDENTITY CASCADE;

    -- Step 2: Insert fresh data from Staging with all necessary JOINS
    INSERT INTO Dim.Dim_Product (
        product_id, 
        product_name, 
        category_name, 
        category_description, 
        supplier_name, 
        supplier_phone, 
        supplier_state_name, 
        unit_price, 
        reorder_level,
        discontinued,
        units_in_stock,
        units_on_order,
        is_current,
        start_date
    )
    SELECT 
        p.product_id, 
        p.product_name, 
        COALESCE(c.category_name, 'Unknown'), 
        c.description, 
        COALESCE(s.company_name, 'Unknown'), 
        s.phone, 
        st.state_name, 
        p.unit_price,      
        p.reorder_level,
        p.discontinued::boolean,
        p.units_in_stock,
        p.units_on_order,
        TRUE,
        CURRENT_TIMESTAMP
    FROM stg.products p
    LEFT JOIN stg.categories c ON p.category_id = c.category_id
    LEFT JOIN stg.suppliers s ON p.supplier_id = s.supplier_id
    LEFT JOIN stg.us_states st ON s.region = st.state_abbr;

    COMMIT;
END;
$$;






-- CALL Dim.Load_Dim_Product();

select * from dim.dim_Product



CREATE OR REPLACE PROCEDURE Dim.Load_Dim_Customer()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear the table and reset the identity sequence
    TRUNCATE TABLE Dim.Dim_Customer RESTART IDENTITY CASCADE;

    -- Step 2: Standardizing and Loading Data
    INSERT INTO Dim.Dim_Customer (
        customer_id, company_name, contact_name, city, 
        postal_code, country, region, phone, 
        state_name, state_abbr, customer_type, customer_desc,
        is_current -- Adding flag from your schema
    )
    SELECT 
        c.customer_id, 
        COALESCE(c.company_name, 'Unknown'),
        COALESCE(c.contact_name, 'Unknown'),
        COALESCE(c.city, 'Unknown'),
        COALESCE(c.postal_code, 'Unknown'),
        COALESCE(c.country, 'Unknown'),
        COALESCE(c.region, 'Unknown'), 
        COALESCE(c.phone, 'Unknown'), 
        COALESCE(s.state_name, 'Unknown'), 
        COALESCE(s.state_abbr, 'Unknown'), 
        COALESCE(cd.customer_type_id, 'General'), 
        COALESCE(cd.customer_desc, 'No Description Available'),
        TRUE -- Marking records as current
    FROM stg.customers c
    LEFT JOIN stg.us_states s ON c.region = s.state_abbr
    LEFT JOIN stg.customer_customer_demo ccd ON c.customer_id = ccd.customer_id
    LEFT JOIN stg.customer_demographics cd ON ccd.customer_type_id = cd.customer_type_id;

    -- Step 3: Critical Commit for visibility
    COMMIT;
END;
$$;



call Dim.Load_Dim_Customer()


select * from dim.dim_customer




/* English comments: 
   Stored Procedure to load Dim_Employee from Staging.
   Includes formatting for full_name and handling NULLs.
*/

CREATE OR REPLACE PROCEDURE Dim.Load_Dim_Employee()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear the table and reset the identity sequence
    TRUNCATE TABLE Dim.Dim_Employee RESTART IDENTITY CASCADE;

    -- Step 2: Loading Data with Transformation
    INSERT INTO Dim.Dim_Employee (
        employee_id, 
        full_name, 
        title, 
        hire_date, 
        city, 
        home_phone, 
        reports_to,
        is_current -- Added based on your schema
    )
    SELECT 
        employee_id, 
        COALESCE(first_name || ' ' || last_name, 'Unknown'),
        COALESCE(title, 'Staff'),
        hire_date,
        COALESCE(city, 'Unknown'),
        COALESCE(home_phone, 'Unknown'),
        reports_to,
        TRUE -- Standard flag for current records
    FROM stg.employees;

    -- Step 3: Crucial for OLE DB and PostgreSQL connectivity
    COMMIT;
END;
$$;


call Dim.Load_Dim_Employee()

select * from dim.dim_employee






/* English comments: 
   Stored Procedure to load Dim_Territory from Staging.
   Includes TRIM for data cleaning and COALESCE for regions.
*/

CREATE OR REPLACE PROCEDURE Dim.Load_Dim_Territory()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear the table and reset the identity
    TRUNCATE TABLE Dim.Dim_Territory RESTART IDENTITY CASCADE;

    -- Step 2: Load cleaned and joined data
    INSERT INTO Dim.Dim_Territory (
        territory_id, 
        territory_description, 
        region_description
    )
    SELECT 
        t.territory_id,
        TRIM(t.territory_description), -- Removes extra spaces from Northwind source
        COALESCE(r.region_description, 'General Region')
    FROM stg.territories t 
    LEFT JOIN stg.region r ON t.region_id = r.region_id;

    -- Step 3: Crucial Commit for visibility in SSIS
    COMMIT;
END;
$$;

call Dim.Load_Dim_Territory()

select * from dim.dim_Territory



CREATE OR REPLACE PROCEDURE Dim.Load_Dim_Shipper()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear the table and reset the identity
    TRUNCATE TABLE Dim.Dim_Shipper RESTART IDENTITY CASCADE;

    -- Step 2: Load data from staging
    INSERT INTO Dim.Dim_Shipper (
        shipper_id, 
        company_name, 
        phone
    )
    SELECT 
        shipper_id::INT, 
        company_name, 
        phone
    FROM stg.shippers;

    -- Step 3: Critical Commit for SSIS visibility
    COMMIT;
END;
$$;


call Dim.Load_Dim_Shipper()


select * FROM dim.dim_shipper





/* English comments: 
   Stored Procedure to generate Dim_Date records.
   Generates a date range from 1990 to 2000 dynamically.
*/

CREATE OR REPLACE PROCEDURE Dim.Load_Dim_Date()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear the table (Date dimension usually loaded once or refreshed)
    TRUNCATE TABLE Dim.Dim_Date CASCADE;

    -- Step 2: Generate and Insert Data
    INSERT INTO Dim.Dim_Date (
        date_key,
        full_date,
        day_name,
        month_name,
        quarter,
        year,
        is_weekend
    )
    SELECT 
        CAST(TO_CHAR(datum, 'YYYYMMDD') AS INT) AS date_key,
        datum AS full_date,
        TO_CHAR(datum, 'TMDay') AS day_name, -- 'TM' for translation-safe names
        TO_CHAR(datum, 'TMMonth') AS month_name,
        EXTRACT(QUARTER FROM datum) AS quarter,
        EXTRACT(YEAR FROM datum) AS year,
        CASE 
            WHEN EXTRACT(ISODOW FROM datum) IN (6, 7) THEN TRUE 
            ELSE FALSE 
        END AS is_weekend
    FROM generate_series(
        '1990-01-01'::DATE, 
        '2000-12-31'::DATE, 
        '1 day'::INTERVAL
    ) AS datum;

    -- Step 3: Commit to ensure persistence in SSIS
    COMMIT;
END;
$$;


call Dim.Load_Dim_Date()

select * from dim.dim_date




/* English comments: 
   Stored Procedure to load the Bridge table.
   Resolves Many-to-Many relationship between Employees and Territories.
   Joins Staging with Dimension tables to get Surrogate Keys.
*/

CREATE OR REPLACE PROCEDURE Bridge.Load_Employee_Territory()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear the bridge table
    TRUNCATE TABLE Bridge.Employee_Territory CASCADE;

    -- Step 2: Mapping Natural Keys from Staging to Surrogate Keys in Dimensions
    INSERT INTO Bridge.Employee_Territory (employee_key, territory_key)
    SELECT 
        e.employee_key, 
        t.territory_key
    FROM stg.employee_territories et
    JOIN Dim.Dim_Employee e ON et.employee_id = e.employee_id
    JOIN Dim.Dim_Territory t ON et.territory_id = t.territory_id;

    -- Step 3: Commit to ensure data is visible in the DWH
    COMMIT;
END;
$$;

call Bridge.Load_Employee_Territory()

select * from Bridge.Employee_Territory







/* English comments: 
   Main Fact Table Load - Fact_Sales.
   Joins Staging Orders with all Dimension tables to resolve Surrogate Keys.
*/

CREATE OR REPLACE PROCEDURE Fact.Load_Fact_Sales()
LANGUAGE plpgsql
AS $$
BEGIN
    -- Step 1: Clear existing Fact data (Full Refresh strategy)
    TRUNCATE TABLE Fact.Fact_Sales CASCADE;

    -- Step 2: Insert Fact records by joining Staging with Dimensions
    INSERT INTO Fact.Fact_Sales (
        product_key, customer_key, employee_key, shipper_key, 
        date_key, order_id, quantity, unit_price_sold, discount, freight
    )
    SELECT 
        p.product_key,
        c.customer_key,
        e.employee_key,
        s.shipper_key,
        d.date_key,
        o.order_id,
        od.quantity,
        od.unit_price,
        od.discount,
        o.freight
    FROM stg.orders o
    JOIN stg.order_details od ON o.order_id = od.order_id
    JOIN Dim.Dim_Product p ON od.product_id = p.product_id
    JOIN Dim.Dim_Customer c ON o.customer_id = c.customer_id
    JOIN Dim.Dim_Employee e ON o.employee_id = e.employee_id
    JOIN Dim.Dim_Shipper s ON o.ship_via = s.shipper_id
    JOIN Dim.Dim_Date d ON o.order_date = d.full_date;

    -- Step 3: Final Commit for transaction persistence
    COMMIT;
END;
$$;

call Fact.Load_Fact_Sales()

select * from fact.fact_sales


