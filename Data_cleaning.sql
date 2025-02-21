-- Create a cleaned table
CREATE TABLE cleaned_product_data AS
SELECT 
    LOWER(TRIM(Product_type)) AS product_type, 
    SKU, 
    ROUND(Price, 2) AS price, 
    COALESCE(Availability, 0) AS availability, 
    COALESCE(Number_of_products_sold, 0) AS number_of_products_sold, 
    ROUND(COALESCE(Revenue_generated, 0), 2) AS revenue_generated, 
    LOWER(TRIM(Customer_demographics)) AS customer_demographics,
    COALESCE(Stock_levels, 0) AS stock_levels, 
    COALESCE(Lead_times, 0) AS lead_times, 
    COALESCE(Order_quantities, 0) AS order_quantities, 
    COALESCE(Shipping_times, 0) AS shipping_times, 
    LOWER(TRIM(Shipping_carriers)) AS shipping_carriers, 
    ROUND(COALESCE(Shipping_costs, 0), 2) AS shipping_costs, 
    LOWER(TRIM(Supplier_name)) AS supplier_name, 
    LOWER(TRIM(Location)) AS location, 
    COALESCE(Lead_time, 0) AS lead_time, 
    COALESCE(Production_volumes, 0) AS production_volumes, 
    COALESCE(Manufacturing_lead_time, 0) AS manufacturing_lead_time, 
    ROUND(COALESCE(Manufacturing_costs, 0), 2) AS manufacturing_costs, 
    LOWER(TRIM(Inspection_results)) AS inspection_results, 
    ROUND(COALESCE(Defect_rates, 0), 4) AS defect_rates, 
    LOWER(TRIM(Transportation_modes)) AS transportation_modes, 
    LOWER(TRIM(Routes)) AS routes, 
    ROUND(COALESCE(Costs, 0), 2) AS costs,
    ROUND(COALESCE(Revenue_generated, 0) - COALESCE(Costs, 0), 2) AS profit_margin,
    CASE 
        WHEN COALESCE(Defect_rates, 0) < 1 THEN 'Low'
        WHEN COALESCE(Defect_rates, 0) BETWEEN 1 AND 3 THEN 'Medium'
        ELSE 'High'
    END AS defect_category
FROM raw_product_data
