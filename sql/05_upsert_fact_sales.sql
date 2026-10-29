-- =========================================================================
-- Phase 2: Upsert / Load Fact Sales from stg to dw
-- =========================================================================
USE `dw`;

-- Clear fact table for clean idempotent rebuilds
TRUNCATE TABLE `fact_sales`;

INSERT INTO `fact_sales` (
    `order_id`,
    `customer_id_sk_fk`,
    `employee_id_sk_fk`,
    `product_id_sk_fk`,
    `shipper_id_sk_fk`,
    `order_date_id_sk_fk`,
    `required_date_id_sk_fk`,
    `shipped_date_id_sk_fk`,
    `quantity`,
    `unit_price`,
    `discount`,
    `freight`,
    `ship_name`,
    `ship_address`,
    `ship_city`,
    `ship_region`,
    `ship_postal_code`,
    `ship_country`
)
SELECT 
    od.OrderID AS order_id,
    c.customer_id_sk_pk AS customer_id_sk_fk,
    e.employee_id_sk_pk AS employee_id_sk_fk,
    p.product_id_sk_pk AS product_id_sk_fk,
    s.shipper_id_sk_pk AS shipper_id_sk_fk,
    COALESCE(DATE_FORMAT(STR_TO_DATE(LEFT(o.OrderDate, 10), '%Y-%m-%d'), '%Y%m%d'), 0) AS order_date_id_sk_fk,
    COALESCE(DATE_FORMAT(STR_TO_DATE(LEFT(o.RequiredDate, 10), '%Y-%m-%d'), '%Y%m%d'), 0) AS required_date_id_sk_fk,
    NULLIF(DATE_FORMAT(STR_TO_DATE(LEFT(o.ShippedDate, 10), '%Y-%m-%d'), '%Y%m%d'), NULL) AS shipped_date_id_sk_fk,
    od.Quantity AS quantity,
    od.UnitPrice AS unit_price,
    od.Discount AS discount,
    o.Freight AS freight,
    o.ShipName AS ship_name,
    o.ShipAddress AS ship_address,
    o.ShipCity AS ship_city,
    o.ShipRegion AS ship_region,
    o.ShipPostalCode AS ship_postal_code,
    o.ShipCountry AS ship_country
FROM stg.order_details od
JOIN stg.orders o ON od.OrderID = o.OrderID
LEFT JOIN `dim_customers` c ON o.CustomerID = c.customer_id_nk
LEFT JOIN `dim_employees` e ON o.EmployeeID = e.employee_id_nk
LEFT JOIN `dim_products` p ON od.ProductID = p.product_id_nk
LEFT JOIN `dim_shippers` s ON o.ShipVia = s.shipper_id_nk;