-- Upsert / Load Dimensions from stg to dw

USE `dw`;

-- 1. Dim Categories
INSERT INTO `dim_categories` (`category_id_nk`, `category_name`, `description`)
SELECT CategoryID, CategoryName, Description 
FROM stg.categories AS src
WHERE CategoryID IS NOT NULL
ON DUPLICATE KEY UPDATE 
    `category_name` = VALUES(`category_name`),
    `description` = VALUES(`description`);

-- 2. Dim Customers
INSERT INTO `dim_customers` (`customer_id_nk`, `company_name`, `contact_name`, `contact_title`, `address`, `city`, `region`, `postal_code`, `country`, `phone`, `fax`)
SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax
FROM stg.customers AS src
WHERE CustomerID IS NOT NULL AND CustomerID != ''
ON DUPLICATE KEY UPDATE 
    `company_name` = VALUES(`company_name`),
    `contact_name` = VALUES(`contact_name`),
    `contact_title` = VALUES(`contact_title`),
    `address` = VALUES(`address`),
    `city` = VALUES(`city`),
    `region` = VALUES(`region`),
    `postal_code` = VALUES(`postal_code`),
    `country` = VALUES(`country`),
    `phone` = VALUES(`phone`),
    `fax` = VALUES(`fax`);

-- 3. Dim Employees
-- Temporarily disable foreign key checks to allow self-referencing hierarchy inserts
SET FOREIGN_KEY_CHECKS = 0;

-- 3. Dim Employees
SET FOREIGN_KEY_CHECKS = 0;
INSERT INTO `dim_employees` (`employee_id_nk`, `last_name`, `first_name`, `title`, `title_of_courtesy`, `birth_date`, `hire_date`, `address`, `city`, `region`, `postal_code`, `country`, `home_phone`, `extension`, `notes`, `reports_to`)
SELECT EmployeeID, LastName, FirstName, Title, TitleOfCourtesy, BirthDate, HireDate, Address, City, Region, PostalCode, Country, HomePhone, Extension, Notes, ReportsTo
FROM stg.employees AS src
WHERE EmployeeID IS NOT NULL
ON DUPLICATE KEY UPDATE 
    `last_name` = VALUES(`last_name`),
    `first_name` = VALUES(`first_name`),
    `title` = VALUES(`title`),
    `title_of_courtesy` = VALUES(`title_of_courtesy`),
    `birth_date` = VALUES(`birth_date`),
    `hire_date` = VALUES(`hire_date`),
    `address` = VALUES(`address`),
    `city` = VALUES(`city`),
    `region` = VALUES(`region`),
    `postal_code` = VALUES(`postal_code`),
    `country` = VALUES(`country`),
    `home_phone` = VALUES(`home_phone`),
    `extension` = VALUES(`extension`),
    `notes` = VALUES(`notes`),
    `reports_to` = VALUES(`reports_to`);
    
SET FOREIGN_KEY_CHECKS = 1;

-- 4. Dim Suppliers
INSERT INTO `dim_suppliers` (`supplier_id_nk`, `company_name`, `contact_name`, `contact_title`, `address`, `city`, `region`, `postal_code`, `country`, `phone`, `fax`)
SELECT SupplierID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax
FROM stg.suppliers AS src
WHERE SupplierID IS NOT NULL
ON DUPLICATE KEY UPDATE 
    `company_name` = VALUES(`company_name`),
    `contact_name` = VALUES(`contact_name`),
    `contact_title` = VALUES(`contact_title`),
    `address` = VALUES(`address`),
    `city` = VALUES(`city`),
    `region` = VALUES(`region`),
    `postal_code` = VALUES(`postal_code`),
    `country` = VALUES(`country`),
    `phone` = VALUES(`phone`),
    `fax` = VALUES(`fax`);

-- 5. Dim Shippers
INSERT INTO `dim_shippers` (`shipper_id_nk`, `company_name`, `phone`)
SELECT ShipperID, CompanyName, Phone
FROM stg.shippers AS src
WHERE ShipperID IS NOT NULL
ON DUPLICATE KEY UPDATE 
    `company_name` = VALUES(`company_name`),
    `phone` = VALUES(`phone`);

-- 6. Dim Regions
INSERT INTO `dim_regions` (`region_id_nk`, `region_description`)
SELECT RegionID, RegionDescription
FROM stg.regions AS src
WHERE RegionID IS NOT NULL
ON DUPLICATE KEY UPDATE 
    `region_description` = VALUES(`region_description`);

-- 7. Dim Territories
INSERT INTO `dim_territories` (`territory_id_nk`, `territory_description`, `region_id_sk_fk`)
SELECT t.TerritoryID, t.TerritoryDescription, r.region_id_sk_pk
FROM stg.territories t
LEFT JOIN `dim_regions` r ON t.RegionID = r.region_id_nk
WHERE t.TerritoryID IS NOT NULL AND t.TerritoryID != ''
ON DUPLICATE KEY UPDATE 
    `territory_description` = VALUES(`territory_description`),
    `region_id_sk_fk` = VALUES(`region_id_sk_fk`);

-- 8. Dim Products
INSERT INTO `dim_products` (`product_id_nk`, `product_name`, `supplier_id_sk_fk`, `category_id_sk_fk`, `quantity_per_unit`, `unit_price`, `units_in_stock`, `units_on_order`, `reorder_level`, `discontinued`)
SELECT p.ProductID, p.ProductName, s.supplier_id_sk_pk, c.category_id_sk_pk, p.QuantityPerUnit, p.UnitPrice, p.UnitsInStock, p.UnitsOnOrder, p.ReorderLevel, p.Discontinued
FROM stg.products p
LEFT JOIN `dim_suppliers` s ON p.SupplierID = s.supplier_id_nk
LEFT JOIN `dim_categories` c ON p.CategoryID = c.category_id_nk
WHERE p.ProductID IS NOT NULL
ON DUPLICATE KEY UPDATE 
    `product_name` = VALUES(`product_name`),
    `supplier_id_sk_fk` = VALUES(`supplier_id_sk_fk`),
    `category_id_sk_fk` = VALUES(`category_id_sk_fk`),
    `quantity_per_unit` = VALUES(`quantity_per_unit`),
    `unit_price` = VALUES(`unit_price`),
    `units_in_stock` = VALUES(`units_in_stock`),
    `units_on_order` = VALUES(`units_on_order`),
    `reorder_level` = VALUES(`reorder_level`),
    `discontinued` = VALUES(`discontinued`);

-- 9. Dim Employee Territories (Using INSERT IGNORE since it has a composite primary key)
INSERT IGNORE INTO `dim_employee_territories` (`employee_id_sk_fk`, `territory_id_sk_fk`)
SELECT e.employee_id_sk_pk, t.territory_id_sk_pk
FROM stg.employee_territories et
JOIN `dim_employees` e ON et.EmployeeID = e.employee_id_nk
JOIN `dim_territories` t ON et.TerritoryID = t.territory_id_nk
WHERE et.EmployeeID IS NOT NULL AND et.TerritoryID IS NOT NULL;