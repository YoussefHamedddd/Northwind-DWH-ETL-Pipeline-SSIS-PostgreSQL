-- 1. Region
INSERT INTO Stg.region (region_id, region_description)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT region_id, region_description FROM region')
AS t(region_id smallint, region_description bpchar);



-- 2. Categories
INSERT INTO Stg.categories (category_id, category_name, description, picture)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT category_id, category_name, description, picture FROM categories')
AS t(category_id smallint, category_name varchar, description text, picture bytea);



-- 3. Suppliers
INSERT INTO Stg.suppliers (supplier_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax, homepage)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT supplier_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax, homepage FROM suppliers')
AS t(supplier_id smallint, company_name varchar, contact_name varchar, contact_title varchar, address varchar, city varchar, region varchar, postal_code varchar, country varchar, phone varchar, fax varchar, homepage text);



-- 4. Shippers
INSERT INTO Stg.shippers (shipper_id, company_name, phone)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT shipper_id, company_name, phone FROM shippers')
AS t(shipper_id smallint, company_name varchar, phone varchar);



-- 5. Customer Demographics
INSERT INTO Stg.customer_demographics (customer_type_id, customer_desc)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT customer_type_id, customer_desc FROM customer_demographics')
AS t(customer_type_id bpchar, customer_desc text);



-- 6. US States
INSERT INTO Stg.us_states (state_id, state_name, state_abbr, state_region)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT state_id, state_name, state_abbr, state_region FROM us_states')
AS t(state_id smallint, state_name varchar, state_abbr varchar, state_region varchar);





-- 7. Territories 
INSERT INTO Stg.territories (territory_id, territory_description, region_id)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT territory_id, territory_description, region_id FROM territories')
AS t(territory_id varchar, territory_description bpchar, region_id smallint);



-- 8. Products
INSERT INTO Stg.products (product_id, product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT product_id, product_name, supplier_id, category_id, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued FROM products')
AS t(product_id smallint, product_name varchar, supplier_id smallint, category_id smallint, quantity_per_unit varchar, unit_price real, units_in_stock smallint, units_on_order smallint, reorder_level smallint, discontinued integer);



--9. Employees
INSERT INTO Stg.employees (employee_id, last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, region, postal_code, country, home_phone, extension, photo, notes, reports_to, photo_path)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT employee_id, last_name, first_name, title, title_of_courtesy, birth_date, hire_date, address, city, region, postal_code, country, home_phone, extension, photo, notes, reports_to, photo_path FROM employees')
AS t(employee_id smallint, last_name varchar, first_name varchar, title varchar, title_of_courtesy varchar, birth_date date, hire_date date, address varchar, city varchar, region varchar, postal_code varchar, country varchar, home_phone varchar, extension varchar, photo bytea, notes text, reports_to smallint, photo_path varchar);



-- 10. Employee Territories 
INSERT INTO Stg.employee_territories (employee_id, territory_id)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT employee_id, territory_id FROM employee_territories')
AS t(employee_id smallint, territory_id varchar);



-- 11. Customer Customer Demo
INSERT INTO Stg.customer_customer_demo (customer_id, customer_type_id)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT customer_id, customer_type_id FROM customer_customer_demo')
AS t(customer_id bpchar, customer_type_id bpchar);



-- 12. Customers
INSERT INTO Stg.customers (customer_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT customer_id, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax FROM customers')
AS t(customer_id bpchar, company_name varchar, contact_name varchar, contact_title varchar, address varchar, city varchar, region varchar, postal_code varchar, country varchar, phone varchar, fax varchar);



-- 13. orders
INSERT INTO Stg.orders (order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT order_id, customer_id, employee_id, order_date, required_date, shipped_date, ship_via, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country FROM orders')
AS t(order_id smallint, customer_id bpchar, employee_id smallint, order_date date, required_date date, shipped_date date, ship_via smallint, freight real, ship_name varchar, ship_address varchar, ship_city varchar, ship_region varchar, ship_postal_code varchar, ship_country varchar);



-- 14. orders_details
INSERT INTO Stg.order_details (order_id, product_id, unit_price, quantity, discount)
SELECT * FROM dblink('host=localhost dbname=northwind user=postgres password=12345',
                     'SELECT order_id, product_id, unit_price, quantity, discount FROM order_details')
AS t(order_id smallint, product_id smallint, unit_price real, quantity smallint, discount real);


