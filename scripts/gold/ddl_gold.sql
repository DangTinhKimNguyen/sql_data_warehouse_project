/*
==========================================================================================
DDL Script: Create Gold Views
==========================================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)
    
    Each view performs transformations and combines data 
    from the Silver layer to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
==========================================================================================
*/

-- ================================================
-- Create Dimension: gold.dim_customers
-- ================================================
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS Customer_key,
	ci.cst_id AS Customer_id,
	ci.cst_key AS Customer_number,
	ci.cst_firstname AS First_name,
	ci.cst_latsname AS Last_name,
	ci.cst_material_status AS Material_status,
	CASE WHEN ci.cst_gndr != 'N/A' THEN ci.cst_gndr
		ELSE COALESCE(ca.gen, 'N/A')
	END AS Gender,
	ci.cst_create_date AS Create_date,
	ca.bdate AS Birthdate,
	la.cntry AS Country
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;
GO

-- ================================================
-- Create Dimension: gold.dim_products
-- ================================================
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
SELECT 
	ROW_NUMBER() OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS Product_key,
	pn.prd_id AS Product_id,
	pn.prd_key AS Product_number,
	pn.prd_nm AS Product_name,
	pn.cat_id AS Category_id,
	pc.cat AS Category,
	pc.subcat AS Subcategory,
	pc.maintenance AS Maintenance,
	pn.prd_cost AS Cost,
	pn.prd_line AS Product_line,
	pn.prd_start_dt AS Start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc
ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL;
GO

-- ================================================
-- Create Fact: gold.fact_sales
-- ================================================
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
SELECT
	sd.sls_ord_num AS Ordrer_number,
	pr.Product_key,
	cu.Customer_key,
	sd.sls_order_dt AS Order_date,
	sd.sls_ship_dt AS Ship_date,
	sd.sls_due_dt AS Due_date,
	sd.sls_sales AS Sales_amount,
	sd.sls_quantity AS Quantity,
	sd.sls_price AS Price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customers cu
on sd.sls_cust_id = cu.Customer_id;
GO
