-- Creating 1:1 raw staging tables for the 11 Northwind datasets.

USE `stg`;

-- Drop tables if they already exist

DROP TABLE IF EXISTS `order_details`;
DROP TABLE IF EXISTS `orders`;
DROP TABLE IF EXISTS `employee_territories`;
DROP TABLE IF EXISTS `employees`;
DROP TABLE IF EXISTS `products`;
DROP TABLE IF EXISTS `suppliers`;
DROP TABLE IF EXISTS `categories`;
DROP TABLE IF EXISTS `customers`;
DROP TABLE IF EXISTS `shippers`;
DROP TABLE IF EXISTS `territories`;
DROP TABLE IF EXISTS `regions`;

-- 1. Categories Table
CREATE TABLE `categories` (
    `CategoryID` INT,
    `CategoryName` VARCHAR(50),
    `Description` TEXT,
    `Picture` LONGTEXT
);

-- 2. Customers Table
CREATE TABLE `customers` (
    `CustomerID` VARCHAR(50),
    `CompanyName` VARCHAR(150),
    `ContactName` VARCHAR(100),
    `ContactTitle` VARCHAR(100),
    `Address` VARCHAR(255),
    `City` VARCHAR(100),
    `Region` VARCHAR(100),
    `PostalCode` VARCHAR(50),
    `Country` VARCHAR(100),
    `Phone` VARCHAR(50),
    `Fax` VARCHAR(50)
);

-- 3. Employees Table
CREATE TABLE `employees` (
    `EmployeeID` INT,
    `LastName` VARCHAR(50),
    `FirstName` VARCHAR(50),
    `Title` VARCHAR(50),
    `TitleOfCourtesy` VARCHAR(25),
    `BirthDate` VARCHAR(50),
    `HireDate` VARCHAR(50),
    `Address` VARCHAR(100),
    `City` VARCHAR(50),
    `Region` VARCHAR(50),
    `PostalCode` VARCHAR(50),
    `Country` VARCHAR(100),
    `HomePhone` VARCHAR(50),
    `Extension` VARCHAR(20),
    `Photo` LONGTEXT,
    `Notes` TEXT,
    `ReportsTo` VARCHAR(50),
    `PhotoPath` VARCHAR(255)
);

-- 4. Employee Territories Table
CREATE TABLE `employee_territories` (
    `EmployeeID` INT,
    `TerritoryID` VARCHAR(50)
);

-- 5. Order Details Table
CREATE TABLE `order_details` (
    `OrderID` INT,
    `ProductID` INT,
    `UnitPrice` DECIMAL(10, 2),
    `Quantity` INT,
    `Discount` DECIMAL(4, 2)
);

-- 6. Orders Table
CREATE TABLE `orders` (
    `OrderID` INT,
    `CustomerID` VARCHAR(50),
    `EmployeeID` INT,
    `OrderDate` VARCHAR(50),
    `RequiredDate` VARCHAR(50),
    `ShippedDate` VARCHAR(50),
    `ShipVia` INT,
    `Freight` DECIMAL(10, 2),
    `ShipName` VARCHAR(150),
    `ShipAddress` VARCHAR(255),
    `ShipCity` VARCHAR(100),
    `ShipRegion` VARCHAR(100),
    `ShipPostalCode` VARCHAR(50),
    `ShipCountry` VARCHAR(100)
);

-- 7. Products Table
CREATE TABLE `products` (
    `ProductID` INT,
    `ProductName` VARCHAR(150),
    `SupplierID` INT,
    `CategoryID` INT,
    `QuantityPerUnit` VARCHAR(100),
    `UnitPrice` DECIMAL(10, 2),
    `UnitsInStock` INT,
    `UnitsOnOrder` INT,
    `ReorderLevel` INT,
    `Discontinued` INT
);

-- 8. Region Table
CREATE TABLE `regions` (
    `RegionID` INT,
    `RegionDescription` VARCHAR(100)
);

-- 9. Shippers Table
CREATE TABLE `shippers` (
    `ShipperID` INT,
    `CompanyName` VARCHAR(100),
    `Phone` VARCHAR(50)
);

-- 10. Suppliers Table
CREATE TABLE `suppliers` (
    `SupplierID` INT,
    `CompanyName` VARCHAR(150),
    `ContactName` VARCHAR(100),
    `ContactTitle` VARCHAR(100),
    `Address` VARCHAR(255),
    `City` VARCHAR(100),
    `Region` VARCHAR(100),
    `PostalCode` VARCHAR(50),
    `Country` VARCHAR(100),
    `Phone` VARCHAR(50),
    `Fax` VARCHAR(50),
    `HomePage` TEXT
);

-- 11. Territories Table
CREATE TABLE `territories` (
    `TerritoryID` VARCHAR(50),
    `TerritoryDescription` VARCHAR(100),
    `RegionID` INT
);