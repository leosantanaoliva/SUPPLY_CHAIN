-- Product Dimension Table
CREATE TABLE dim_products (
    product_id SERIAL PRIMARY KEY,
    sku VARCHAR UNIQUE,
    product_type VARCHAR,
    price DECIMAL(10,2),
    stock_levels INT
);

INSERT INTO dim_products (sku, product_type, price, stock_levels)
SELECT DISTINCT SKU, LOWER(TRIM(Product_type)), ROUND(Price, 2), COALESCE(Stock_levels, 0)
FROM cleaned_product_data;


-- Supplier Dimension Table
CREATE TABLE dim_suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR UNIQUE,
    location VARCHAR
);

INSERT INTO dim_suppliers (supplier_name, location)
SELECT DISTINCT LOWER(TRIM(Supplier_name)), LOWER(TRIM(Location))
FROM cleaned_product_data;


-- Shipping Dimension Table
CREATE TABLE dim_shipping (
    shipping_id SERIAL PRIMARY KEY,
    shipping_carriers VARCHAR UNIQUE,
    shipping_costs DECIMAL(10,2),
    shipping_times INT
);

INSERT INTO dim_shipping (shipping_carriers, shipping_costs, shipping_times)
SELECT DISTINCT LOWER(TRIM(Shipping_carriers)), ROUND(COALESCE(Shipping_costs, 2), 2), COALESCE(Shipping_times, 0)
FROM cleaned_product_data;


-- Manufacturing Dimension Table
CREATE TABLE dim_manufacturing (
    manufacturing_id SERIAL PRIMARY KEY,
    sku VARCHAR UNIQUE REFERENCES dim_products(sku),
    lead_time INT,
    production_volumes INT,
    manufacturing_lead_time INT,
    manufacturing_costs DECIMAL(12,2)
);

INSERT INTO dim_manufacturing (sku, lead_time, production_volumes, manufacturing_lead_time, manufacturing_costs)
SELECT DISTINCT SKU, COALESCE(Lead_time, 0), COALESCE(Production_volumes, 0), COALESCE(Manufacturing_lead_time, 0), ROUND(COALESCE(Manufacturing_costs, 0), 2)
FROM cleaned_product_data;


-- Quality Control Dimension Table
CREATE TABLE dim_quality_control (
    qc_id SERIAL PRIMARY KEY,
    sku VARCHAR UNIQUE REFERENCES dim_products(sku),
    inspection_results VARCHAR,
    defect_rates DECIMAL(5,4),
    defect_category VARCHAR
);

INSERT INTO dim_quality_control (sku, inspection_results, defect_rates, defect_category)
SELECT DISTINCT SKU, LOWER(TRIM(Inspection_results)), ROUND(COALESCE(Defect_rates, 0), 4),
    CASE 
        WHEN COALESCE(Defect_rates, 0) < 1 THEN 'Low'
        WHEN COALESCE(Defect_rates, 0) BETWEEN 1 AND 3 THEN 'Medium'
        ELSE 'High'
    END
FROM cleaned_product_data;


-- Logistics Dimension Table
CREATE TABLE dim_logistics (
    logistics_id SERIAL PRIMARY KEY,
    transportation_modes VARCHAR,
    routes VARCHAR,
    costs DECIMAL(10,2)
);

INSERT INTO dim_logistics (transportation_modes, routes, costs)
SELECT DISTINCT LOWER(TRIM(Transportation_modes)), LOWER(TRIM(Routes)), ROUND(COALESCE(Costs, 0), 2)
FROM cleaned_product_data;



CREATE TABLE fact_sales (
    sales_id SERIAL PRIMARY KEY,
    sku VARCHAR REFERENCES dim_products(sku),
    supplier_id INT REFERENCES dim_suppliers(supplier_id),
    shipping_id INT REFERENCES dim_shipping(shipping_id),
    logistics_id INT REFERENCES dim_logistics(logistics_id),
    manufacturing_id INT REFERENCES dim_manufacturing(manufacturing_id),
    qc_id INT REFERENCES dim_quality_control(qc_id),
    availability INT,
    number_of_products_sold INT,
    revenue_generated DECIMAL(12,2),
    order_quantities INT
);

INSERT INTO fact_sales (sku, supplier_id, shipping_id, logistics_id, manufacturing_id, qc_id, 
                        availability, number_of_products_sold, revenue_generated, order_quantities)
SELECT 
    p.sku, 
    s.supplier_id, 
    sh.shipping_id, 
    l.logistics_id, 
    m.manufacturing_id, 
    q.qc_id,
    r.Availability, 
    r.Number_of_products_sold, 
    ROUND(r.Revenue_generated, 2),
    r.Order_quantities
FROM cleaned_product_data r
JOIN dim_products p ON r.SKU = p.sku
JOIN dim_suppliers s ON r.Supplier_name = s.supplier_name AND r.Location = s.location
JOIN dim_shipping sh ON r.Shipping_carriers = sh.shipping_carriers
JOIN dim_logistics l ON r.Transportation_modes = l.transportation_modes AND r.Routes = l.routes
JOIN dim_manufacturing m ON r.SKU = m.sku
JOIN dim_quality_control q ON r.SKU = q.sku;

