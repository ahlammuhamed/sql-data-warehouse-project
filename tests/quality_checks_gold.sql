/*==============================================================================
    GOLD LAYER - DIMENSIONAL MODELING & DATA QUALITY CHECKS
==============================================================================

    Purpose:
        This script contains the validation and preparation queries used to
        build and verify the Gold Layer of the Data Warehouse.

    Gold Layer:
        - Provides business-ready, integrated data.
        - Combines information from CRM and ERP source systems.
        - Implements a Star Schema design.
        - Uses surrogate keys for dimension tables.
        - Provides fact and dimension tables optimized for analytics.

    Main Objects:
        - gold.dim_customers
        - gold.dim_products
        - gold.fact_sales

    Key Validation Areas:
        1. Customer data integration
        2. Customer gender reconciliation
        3. Customer duplicate checks
        4. Product uniqueness validation
        5. Dimension-to-fact relationships
        6. Foreign key integrity checks

==============================================================================*/


/*==============================================================================
    SECTION 01: CUSTOMER DATA INTEGRATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Combine customer information from CRM and ERP source systems
--     into a single customer dataset.
--
-- Data Sources:
--     CRM  -> Customer master information
--     ERP  -> Additional demographic and location information
-- -----------------------------------------------------------------------------

SELECT
    ci.cus_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    la.cntry
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_CUST_AZ12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_LOC_A101 AS la
    ON ci.cst_key = la.cid;


/*==============================================================================
    SECTION 02: CUSTOMER DUPLICATE CHECK
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Verify that joining customer information from multiple sources does not
--     introduce duplicate customer records.
--
-- Expected Result:
--     No customer should appear more than once.
-- -----------------------------------------------------------------------------

SELECT
    cus_id,
    COUNT(*) AS duplicate_count
FROM
(
    SELECT
        ci.cus_id,
        ci.cst_key,
        ci.cst_firstname,
        ci.cst_lastname,
        ci.cst_marital_status,
        ci.cst_gndr,
        ci.cst_create_date,
        ca.bdate,
        ca.gen,
        la.cntry
    FROM silver.crm_cust_info AS ci
    LEFT JOIN silver.erp_CUST_AZ12 AS ca
        ON ci.cst_key = ca.cid
    LEFT JOIN silver.erp_LOC_A101 AS la
        ON ci.cst_key = la.cid
) AS customer_data
GROUP BY
    cus_id
HAVING COUNT(*) > 1;


/*==============================================================================
    SECTION 03: CUSTOMER GENDER RECONCILIATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Compare gender information coming from the CRM and ERP systems.
--
-- Business Rule:
--     CRM is considered the master source for customer information.
--     Therefore, CRM gender takes priority when it contains a valid value.
--     ERP gender is used only when the CRM value is unavailable ('n/a').
-- -----------------------------------------------------------------------------

-- Step 1: Identify differences between CRM and ERP gender values.

SELECT DISTINCT
    ci.cst_gndr AS crm_gender,
    ca.gen       AS erp_gender
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_CUST_AZ12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_LOC_A101 AS la
    ON ci.cst_key = la.cid
ORDER BY
    crm_gender,
    erp_gender;


-- Step 2: Apply the gender reconciliation business rule.

SELECT DISTINCT
    ci.cst_gndr AS crm_gender,
    ca.gen       AS erp_gender,
    CASE
        WHEN ci.cst_gndr <> 'n/a'
            THEN ci.cst_gndr
        ELSE COALESCE(ca.gen, 'n/a')
    END AS new_gender
FROM silver.crm_cust_info AS ci
LEFT JOIN silver.erp_CUST_AZ12 AS ca
    ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_LOC_A101 AS la
    ON ci.cst_key = la.cid
ORDER BY
    crm_gender,
    erp_gender;


/*==============================================================================
    SECTION 04: CUSTOMER DIMENSION DESIGN
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Naming Convention:
--     Use clear, business-friendly column names.
--     Follow snake_case naming convention:
--         lowercase + underscore
--
-- Column Organization:
--     1. Surrogate / business keys
--     2. Personal information
--     3. Demographic information
--     4. Location information
--     5. Date attributes
--
-- Dimension Type:
--     dim_customers is a DIMENSION table.
--
-- Primary Key:
--     A surrogate key is used instead of the source-system customer ID.
--
-- Surrogate Key Options:
--     1. DDL-based generation
--     2. Query-based generation using ROW_NUMBER()
-- -----------------------------------------------------------------------------


/*==============================================================================
    SECTION 05: PRODUCT DATA VALIDATION
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Validate product records before loading the Gold product dimension.
--
-- Business Rule:
--     Historical product versions are not required in the Gold Layer.
--     Therefore, only the current product version is selected where
--     prd_end_dt IS NULL.
-- -----------------------------------------------------------------------------

SELECT
    pn.prd_id,
    pn.cat_id,
    pn.prd_key,
    pn.prd_nm,
    pn.prd_cost,
    pn.prd_line,
    pn.prd_start_dt,
    pc.CAT,
    pc.SUBCAT,
    pc.MAINTENANCE
FROM silver.crm_prd_info AS pn
LEFT JOIN silver.erp_PX_CAT_G1V2 AS pc
    ON pn.cat_id = pc.ID
WHERE pn.prd_end_dt IS NULL;


/*==============================================================================
    SECTION 06: PRODUCT DUPLICATE CHECK
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Ensure that the current product dataset contains only one record
--     per product key.
--
-- Expected Result:
--     No rows should be returned.
-- -----------------------------------------------------------------------------

SELECT
    prd_key,
    COUNT(*) AS duplicate_count
FROM
(
    SELECT
        pn.prd_id,
        pn.cat_id,
        pn.prd_key,
        pn.prd_nm,
        pn.prd_cost,
        pn.prd_line,
        pn.prd_start_dt,
        pc.CAT,
        pc.SUBCAT,
        pc.MAINTENANCE
    FROM silver.crm_prd_info AS pn
    LEFT JOIN silver.erp_PX_CAT_G1V2 AS pc
        ON pn.cat_id = pc.ID
    WHERE pn.prd_end_dt IS NULL
) AS product_data
GROUP BY
    prd_key
HAVING COUNT(*) > 1;


/*==============================================================================
    SECTION 07: GOLD LAYER OBJECT REVIEW
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Review the final Gold Layer dimension and fact tables before performing
--     relationship and integrity validation.
-- -----------------------------------------------------------------------------

SELECT *
FROM gold.dim_customers;

SELECT *
FROM gold.dim_products;

SELECT *
FROM gold.fact_sales;


/*==============================================================================
    SECTION 08: FACT TABLE DESIGN
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Validate the construction of the fact table and its relationships
--     with the dimension tables.
--
-- Design Principle:
--     The fact table stores surrogate keys from the dimensions rather than
--     relying directly on source-system IDs.
--
-- Benefits:
--     - Consistent relationships between fact and dimension tables
--     - Simplified joins
--     - Better support for dimensional modeling
--     - Independence from source-system key structures
--
-- Dimension Lookups:
--     Customer  -> customer_key
--     Product   -> product_key
--     Date      -> date_key (when applicable)
-- -----------------------------------------------------------------------------


/*==============================================================================
    SECTION 09: FACT-TO-DIMENSION RELATIONSHIP CHECK
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Verify that fact records can successfully resolve their corresponding
--     customer and product dimension records.
--
-- Expected Result:
--     Every fact record should have a matching customer and product.
-- -----------------------------------------------------------------------------

SELECT
    f.*,
    c.customer_key,
    p.product_key
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key;


/*==============================================================================
    SECTION 10: FOREIGN KEY INTEGRITY CHECK
==============================================================================*/

-- -----------------------------------------------------------------------------
-- Purpose:
--     Identify orphaned foreign keys in the fact table.
--
-- Expected Result:
--     No rows should be returned.
--
-- If rows are returned:
--     - The fact record references a missing customer dimension record, or
--     - The fact record references a missing product dimension record.
-- -----------------------------------------------------------------------------

SELECT
    f.*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE
    c.customer_key IS NULL
    OR p.product_key IS NULL;


/*==============================================================================
    END OF GOLD LAYER VALIDATION
==============================================================================*/
