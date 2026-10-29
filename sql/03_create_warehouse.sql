-- Phase 2: Data Warehouse DDL (dw Schema & Star Schema Tables)
CREATE DATABASE IF NOT EXISTS `dw`;
USE `dw`;

-- 1. Drop existing tables for clean idempotency
DROP TABLE IF EXISTS `fact_sales`;
DROP TABLE IF EXISTS `dim_employee_territories`;
DROP TABLE IF EXISTS `dim_products`;
DROP TABLE IF EXISTS `dim_territories`;
DROP TABLE IF EXISTS `dim_regions`;
DROP TABLE IF EXISTS `dim_shippers`;
DROP TABLE IF EXISTS `dim_suppliers`;
DROP TABLE IF EXISTS `dim_employees`;
DROP TABLE IF EXISTS `dim_customers`;
DROP TABLE IF EXISTS `dim_categories`;
DROP TABLE IF EXISTS `dim_date`;

-- 2. Date Dimension
CREATE TABLE `dim_date` (
    `date_id_sk_pk` INT PRIMARY KEY, -- Format: YYYYMMDD
    `full_date` DATE NOT NULL,
    `year` INT NOT NULL,
    `quarter` INT NOT NULL,
    `month_number` INT NOT NULL,
    `month_name` VARCHAR(20) NOT NULL,
    `month_short` VARCHAR(3) NOT NULL,
    `week_number` INT NOT NULL,
    `day_of_week` INT NOT NULL,
    `day_name` VARCHAR(20) NOT NULL,
    `is_weekend` BOOLEAN NOT NULL,
    `fiscal_year` INT NOT NULL,
    `fiscal_quarter` INT NOT NULL
);

-- 3. Dimension Tables
CREATE TABLE `dim_categories` (
    `category_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `category_id_nk` INT NOT NULL UNIQUE,
    `category_name` VARCHAR(50),
    `description` TEXT
);

CREATE TABLE `dim_customers` (
    `customer_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `customer_id_nk` VARCHAR(50) NOT NULL UNIQUE,
    `company_name` VARCHAR(150),
    `contact_name` VARCHAR(100),
    `contact_title` VARCHAR(100),
    `address` VARCHAR(100),
    `city` VARCHAR(50),
    `region` VARCHAR(50),
	`postal_code` VARCHAR(50),
	`country` VARCHAR(50),
    `phone` VARCHAR(50),
    `fax` VARCHAR(50)
);

CREATE TABLE `dim_employees` (
    `employee_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `employee_id_nk` INT NOT NULL UNIQUE,
    `last_name` VARCHAR(50) NOT NULL,
    `first_name` VARCHAR(50) NOT NULL,
    `title` VARCHAR(50),
    `title_of_courtesy` VARCHAR(25),
    `birth_date` DATE,
    `hire_date` DATE,
    `address` VARCHAR(100),
    `city` VARCHAR(50),
    `region` VARCHAR(50),
    `postal_code` VARCHAR(50),
    `country` VARCHAR(50),
    `home_phone` VARCHAR(50),
    `extension` VARCHAR(20),
    `notes` TEXT,
    `reports_to` INT,
    CONSTRAINT `fk_dim_employee_manager` 
        FOREIGN KEY (`reports_to`) 
        REFERENCES `dim_employees`(`employee_id_nk`)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE TABLE `dim_suppliers` (
    `supplier_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `supplier_id_nk` INT NOT NULL UNIQUE,
    `company_name` VARCHAR(150),
    `contact_name` VARCHAR(100),    
    `contact_title` VARCHAR(50),
	`address` VARCHAR(100),
    `city` VARCHAR(50),
	`region` VARCHAR(50),    
	`postal_code` VARCHAR(50),
    `country` VARCHAR(50),
    `phone` VARCHAR(50),
    `fax` VARCHAR(50)
);

CREATE TABLE `dim_products` (
    `product_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `product_id_nk` INT NOT NULL UNIQUE,
    `product_name` VARCHAR(150),
    `supplier_id_sk_fk` INT,
    `category_id_sk_fk` INT,
	`quantity_per_unit` VARCHAR(50),
    `unit_price` DECIMAL(10, 2),
    `units_in_stock` INT,
    `units_on_order` INT,
    `reorder_level` INT,
    `discontinued` BOOLEAN NOT NULL,
    FOREIGN KEY (`supplier_id_sk_fk`) REFERENCES `dim_suppliers`(`supplier_id_sk_pk`),
    FOREIGN KEY (`category_id_sk_fk`) REFERENCES `dim_categories`(`category_id_sk_pk`)
);

CREATE TABLE `dim_shippers` (
    `shipper_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `shipper_id_nk` INT NOT NULL UNIQUE,
    `company_name` VARCHAR(100),
    `phone` VARCHAR(50)
);

CREATE TABLE `dim_regions` (
    `region_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `region_id_nk` INT NOT NULL UNIQUE,
    `region_description` VARCHAR(100)
);

CREATE TABLE `dim_territories` (
    `territory_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `territory_id_nk` VARCHAR(50) NOT NULL UNIQUE,
    `territory_description` VARCHAR(100),
    `region_id_sk_fk` INT,
	FOREIGN KEY (`region_id_sk_fk`) REFERENCES `dim_regions`(`region_id_sk_pk`)
);

CREATE TABLE `dim_employee_territories` (
    `employee_id_sk_fk` INT,
    `territory_id_sk_fk` INT,
    PRIMARY KEY (`employee_id_sk_fk`, `territory_id_sk_fk`),
	FOREIGN KEY (`employee_id_sk_fk`) REFERENCES `dim_employees`(`employee_id_sk_pk`),
	FOREIGN KEY (`territory_id_sk_fk`) REFERENCES `dim_territories`(`territory_id_sk_pk`)
);

-- 4. Central Fact Table (fact_sales) referencing Surrogate Keys
CREATE TABLE `fact_sales` (
    `sale_id_sk_pk` INT AUTO_INCREMENT PRIMARY KEY,
    `order_id` INT NOT NULL,
    `customer_id_sk_fk` INT,
    `employee_id_sk_fk` INT,
    `product_id_sk_fk` INT,
    `order_date_id_sk_fk` INT,
    `required_date_id_sk_fk` INT,
    `shipped_date_id_sk_fk` INT,
    `quantity` INT,
    `unit_price` DECIMAL(10, 2),
    `discount` DECIMAL(4, 2),
    `freight` DECIMAL(10, 2),
    `shipper_id_sk_fk` INT,
    `ship_name` VARCHAR(100),
    `ship_address` VARCHAR(100),
    `ship_city` VARCHAR(50),
	`ship_region` VARCHAR(50),
	`ship_postal_code` VARCHAR(50),
	`ship_country` VARCHAR(50),
    FOREIGN KEY (`customer_id_sk_fk`) REFERENCES `dim_customers`(`customer_id_sk_pk`),
    FOREIGN KEY (`employee_id_sk_fk`) REFERENCES `dim_employees`(`employee_id_sk_pk`),
    FOREIGN KEY (`product_id_sk_fk`) REFERENCES `dim_products`(`product_id_sk_pk`),
    FOREIGN KEY (`shipper_id_sk_fk`) REFERENCES `dim_shippers`(`shipper_id_sk_pk`),
    FOREIGN KEY (`order_date_id_sk_fk`) REFERENCES `dim_date`(`date_id_sk_pk`),
    FOREIGN KEY (`required_date_id_sk_fk`) REFERENCES `dim_date`(`date_id_sk_pk`),
    FOREIGN KEY (`shipped_date_id_sk_fk`) REFERENCES `dim_date`(`date_id_sk_pk`)
);