-- =============================================================
-- Silver Layer Quality Checks
-- Database  : DataWarehouse
-- Schema    : Silver
-- Created   : [18 August 2026]
-- Description: This script performs data quality checks on the
--              Silver layer to validate data completeness,
--              uniqueness, consistency, standardization, and
--              accuracy after the transformation process.
--
--              The checks cover:
--              - Null and duplicate records
--              - Data standardization and consistency
--              - Invalid and out-of-range dates
--              - Data integrity between related tables
--              - Business rule validation
--              - Numeric and calculation accuracy
--
-- Usage Notes : Run this checks after data loading silver layer
-- =============================================================


-- =============================================================
-- CRM: Customer Information
-- Table: silver.crm_cust_info
-- =============================================================


-- -------------------------------------------------------------
-- 1. Check for NULL or Duplicate Customer IDs
-- Expected Result: No rows
-- -------------------------------------------------------------
SELECT
    cus_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_cust_info
GROUP BY cus_id
HAVING COUNT(*) > 1
    OR cus_id IS NULL;


-- -------------------------------------------------------------
-- 2. Check for Duplicate Customer Records
-- Expected Result: Only the latest record per customer should remain
-- -------------------------------------------------------------
SELECT *
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY cus_id
            ORDER BY cst_create_date DESC
        ) AS flag_last
    FROM silver.crm_cust_info
) AS t
WHERE flag_last > 1;


-- -------------------------------------------------------------
-- 3. Check for Unwanted Spaces in Customer Names
-- Expected Result: No rows
-- -------------------------------------------------------------
SELECT
    cus_id,
    cst_firstname,
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);


-- -------------------------------------------------------------
-- 4. Check Customer Gender Standardization
-- Expected Values: Male, Female, n/a
-- -------------------------------------------------------------
SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info;


-- -------------------------------------------------------------
-- 5. Check Customer Marital Status Standardization
-- Expected Values: Married, Single, n/a
-- -------------------------------------------------------------
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info;


-- =============================================================
-- CRM: Product Information
-- Table: silver.crm_prd_info
-- =============================================================


-- -------------------------------------------------------------
-- 1. Check for NULL or Duplicate Product IDs
-- Expected Result: No rows
-- -------------------------------------------------------------
SELECT
    prd_id,
    COUNT(*) AS duplicate_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1
    OR prd_id IS NULL;


-- -------------------------------------------------------------
-- 2. Check for Invalid Product Costs
-- Expected Result: No NULL or negative costs
-- -------------------------------------------------------------
SELECT
    prd_id,
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0
   OR prd_cost IS NULL;


-- -------------------------------------------------------------
-- 3. Check Product Line Standardization
-- Expected Values: Mountain, Road, Other Sales, Touring, n/a
-- -------------------------------------------------------------
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info;


-- -------------------------------------------------------------
-- 4. Check Product Date Consistency
-- Expected Result: End date must be greater than or equal to
--                  start date
-- -------------------------------------------------------------
SELECT
    prd_id,
    prd_key,
    prd_start_dt,
    prd_end_dt
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;


-- =============================================================
-- CRM: Sales Details
-- Table: silver.crm_sales_details
-- =============================================================


-- -------------------------------------------------------------
-- 1. Check Invalid Order Dates
-- Expected Result: No invalid dates
-- -------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt IS NULL
   OR sls_order_dt < '1900-01-01'
   OR sls_order_dt > '2050-01-01';


-- -------------------------------------------------------------
-- 2. Check Invalid Shipping Dates
-- Expected Result: No invalid dates
-- -------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_ship_dt
FROM silver.crm_sales_details
WHERE sls_ship_dt IS NULL
   OR sls_ship_dt < '1900-01-01'
   OR sls_ship_dt > '2050-01-01';


-- -------------------------------------------------------------
-- 3. Check Invalid Due Dates
-- Expected Result: No invalid dates
-- -------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_due_dt
FROM silver.crm_sales_details
WHERE sls_due_dt IS NULL
   OR sls_due_dt < '1900-01-01'
   OR sls_due_dt > '2050-01-01';


-- -------------------------------------------------------------
-- 4. Check Order Date Sequence
-- Expected Result:
-- Order Date <= Ship Date
-- Order Date <= Due Date
-- -------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;


-- -------------------------------------------------------------
-- 5. Check Sales Calculation
-- Expected Result:
-- Sales = Quantity × Price
-- -------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_quantity,
    sls_price,
    sls_sales,
    sls_quantity * ABS(sls_price) AS expected_sales
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales != sls_quantity * ABS(sls_price);


-- -------------------------------------------------------------
-- 6. Check Sales Price Consistency
-- Expected Result: No invalid prices
-- -------------------------------------------------------------
SELECT
    sls_ord_num,
    sls_quantity,
    sls_sales,
    sls_price,
    sls_sales / NULLIF(sls_quantity, 0) AS expected_price
FROM silver.crm_sales_details
WHERE sls_price IS NULL
   OR sls_price <= 0
   OR sls_sales IS NULL
   OR sls_quantity IS NULL;


-- =============================================================
-- ERP: Customer Information
-- Table: silver.erp_CUST_AZ12
-- =============================================================


-- -------------------------------------------------------------
-- 1. Check Customer ID Integration
-- Expected Result: Every ERP customer should exist in CRM
-- -------------------------------------------------------------
SELECT
    CID,
    BDATE,
    GEN
FROM silver.erp_CUST_AZ12
WHERE CID NOT IN (
    SELECT DISTINCT
        cst_key
    FROM silver.crm_cust_info
);


-- -------------------------------------------------------------
-- 2. Check Customer Birthdate Range
-- Expected Result: No future dates or extreme dates
-- -------------------------------------------------------------
SELECT
    CID,
    BDATE
FROM silver.erp_CUST_AZ12
WHERE BDATE < '1924-01-01'
   OR BDATE > CAST(GETDATE() AS DATE);


-- -------------------------------------------------------------
-- 3. Check Gender Standardization
-- Expected Values: Male, Female, n/a
-- -------------------------------------------------------------
SELECT DISTINCT
    GEN
FROM silver.erp_CUST_AZ12;


-- =============================================================
-- ERP: Customer Location
-- Table: silver.erp_LOC_A101
-- =============================================================


-- -------------------------------------------------------------
-- 1. Check Customer ID Integration
-- Expected Result: Every ERP location record should have
--                  a matching CRM customer
-- -------------------------------------------------------------
SELECT
    CID,
    CNTRY
FROM silver.erp_LOC_A101
WHERE CID NOT IN (
    SELECT DISTINCT
        cst_key
    FROM silver.crm_cust_info
);


-- -------------------------------------------------------------
-- 2. Check Country Standardization
-- Expected Values: Standardized country names or n/a
-- -------------------------------------------------------------
SELECT DISTINCT
    CNTRY
FROM silver.erp_LOC_A101;


-- -------------------------------------------------------------
-- 3. Check for Unwanted Spaces
-- Expected Result: No rows
-- -------------------------------------------------------------
SELECT
    CID,
    CNTRY
FROM silver.erp_LOC_A101
WHERE CNTRY != TRIM(CNTRY);


-- =============================================================
-- ERP: Product Category
-- Table: silver.erp_PX_CAT_G1V2
-- =============================================================


-- -------------------------------------------------------------
-- 1. Check for Unwanted Spaces
-- Expected Result: No rows
-- -------------------------------------------------------------
SELECT
    ID,
    CAT,
    SUBCAT
FROM silver.erp_PX_CAT_G1V2
WHERE CAT != TRIM(CAT)
   OR SUBCAT != TRIM(SUBCAT);


-- -------------------------------------------------------------
-- 2. Check Category Standardization
-- -------------------------------------------------------------
SELECT DISTINCT
    CAT
FROM silver.erp_PX_CAT_G1V2;


-- -------------------------------------------------------------
-- 3. Check Subcategory Standardization
-- -------------------------------------------------------------
SELECT DISTINCT
    SUBCAT
FROM silver.erp_PX_CAT_G1V2;


-- -------------------------------------------------------------
-- 4. Check Maintenance Values
-- -------------------------------------------------------------
SELECT DISTINCT
    MAINTENANCE
FROM silver.erp_PX_CAT_G1V2;


-- =============================================================
-- End of Silver Layer Quality Checks
-- =============================================================
