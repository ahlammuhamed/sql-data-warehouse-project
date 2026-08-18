/*==============================================================================
Procedure Name : silver.load_silver
Purpose        : Load raw CRM and ERP datasets into the Silver layer.
Layer          : Silver
Project        : Data Warehouse & Analytics Project

Description:
    This procedure truncates Silver tables, cleanses and transforms data
    from the Bronze layer, standardizes values and formats, handles missing
    and invalid data, removes duplicate customer records, and loads the
    validated data into Silver tables.

Parameters:
    This stored procedure doesn't accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
==============================================================================*/


CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN

    DECLARE
        @start_time       DATETIME,
        @end_time         DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time   DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Silver Layer';
        PRINT '==========================================';
        PRINT ' ';


        /*======================================================================
            1. LOADING CRM TABLES
        ======================================================================*/

        PRINT '-------------------------';
        PRINT '|  1-LOADING CRM TABLES  |';
        PRINT '-------------------------';
        PRINT ' ';


        /*--------------------------------------------------------------------------
            1.1 CRM Customer Information
        --------------------------------------------------------------------------*/

        PRINT '1.1. Loading customer information table';
        PRINT '        -------------------------------';
        PRINT '>> Truncating Table : silver.crm_cust_info';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into : silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info
        (
            cus_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cus_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM
        (
            SELECT *,
                ROW_NUMBER() OVER
                (
                    PARTITION BY cus_id
                    ORDER BY cst_create_date DESC
                ) AS flag_last
            FROM bronze.crm_cust_info
            WHERE cus_id IS NOT NULL
        ) AS t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : silver.crm_cust_info';
        PRINT '>> Load Duration  : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
            + ' seconds';

        PRINT '......................';


        /*--------------------------------------------------------------------------
            1.2 CRM Product Information
        --------------------------------------------------------------------------*/

        PRINT ' ';
        PRINT '1.2. Loading product information table';
        PRINT '        ------------------------------';
        PRINT '>> Truncating Table : silver.crm_prd_info';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into : silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info
        (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST
            (
                DATEADD
                (
                    DAY,
                    -1,
                    LEAD(prd_start_dt) OVER
                    (
                        PARTITION BY prd_key
                        ORDER BY prd_start_dt
                    )
                ) AS DATE
            ) AS prd_end_dt
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : silver.crm_prd_info';
        PRINT '>> Load Duration  : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
            + ' seconds';

        PRINT '......................';


        /*--------------------------------------------------------------------------
            1.3 CRM Sales Details
        --------------------------------------------------------------------------*/

        PRINT ' ';
        PRINT '1.3. Loading sales details table';
        PRINT '       -------------------------';
        PRINT '>> Truncating Table : silver.crm_sales_details';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into : silver.crm_sales_details';

        INSERT INTO silver.crm_sales_details
        (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,

            CASE
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS CHAR(8)) AS DATE)
            END AS sls_order_dt,

            CASE
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS CHAR(8)) AS DATE)
            END AS sls_ship_dt,

            CASE
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS CHAR(8)) AS DATE)
            END AS sls_due_dt,

            CASE
                WHEN sls_sales IS NULL
                     OR sls_sales <= 0
                     OR sls_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            sls_quantity,

            CASE
                WHEN sls_price IS NULL OR sls_price <= 0
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE sls_price
            END AS sls_price

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : silver.crm_sales_details';
        PRINT '>> Load Duration  : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
            + ' seconds';

        PRINT '......................';


        /*======================================================================
            2. LOADING ERP TABLES
        ======================================================================*/

        PRINT ' ';
        PRINT '-------------------------';
        PRINT '|  2-LOADING ERP TABLES  |';
        PRINT '-------------------------';
        PRINT ' ';


        /*--------------------------------------------------------------------------
            2.1 ERP Location
        --------------------------------------------------------------------------*/

        PRINT '2.1. Loading location table';
        PRINT '     ----------------------';
        PRINT '>> Truncating Table : silver.erp_LOC_A101';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_LOC_A101;

        PRINT '>> Inserting Data Into : silver.erp_LOC_A101';

        INSERT INTO silver.erp_LOC_A101
        (
            cid,
            cntry
        )
        SELECT
            REPLACE(cid, '-', ''),
            CASE
                WHEN TRIM(cntry) = 'DE'
                    THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA')
                    THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL
                    THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_LOC_A101;

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : silver.erp_LOC_A101';
        PRINT '>> Load Duration  : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
            + ' seconds';

        PRINT '......................';


        /*--------------------------------------------------------------------------
            2.2 ERP Customer Personal Information
        --------------------------------------------------------------------------*/

        PRINT ' ';
        PRINT '2.2. Loading customer personal information table';
        PRINT '        ---------------------------------------';
        PRINT '>> Truncating Table : silver.erp_CUST_AZ12';

        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_CUST_AZ12;

        PRINT '>> Inserting Data Into : silver.erp_CUST_AZ12';

        INSERT INTO silver.erp_CUST_AZ12
        (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN cid LIKE 'NAS%'
                    THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            CASE
                WHEN bdate > GETDATE()
                    THEN NULL
                ELSE bdate
            END AS bdate,

            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE')
                    THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')
                    THEN 'Male'
                ELSE 'n/a'
            END AS gen

        FROM bronze.erp_CUST_AZ12;

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : silver.erp_CUST_AZ12';
        PRINT '>> Load Duration  : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
            + ' seconds';

        PRINT '......................';


        /*--------------------------------------------------------------------------
            2.3 ERP Product Category
        --------------------------------------------------------------------------*/

        PRINT ' ';
        PRINT '2.3. Loading product category table';
        PRINT '        ---------------------------';
        PRINT '>> Truncating Table : silver.erp_PX_CAT_G1V2';
       
        SET @start_time = GETDATE();

        TRUNCATE TABLE silver.erp_PX_CAT_G1V2;

        PRINT '>> Inserting Data Into : silver.erp_PX_CAT_G1V2';

        INSERT INTO silver.erp_PX_CAT_G1V2
        (
            id,
            cat,
            subcat,
            MAINTENANCE
        )
        SELECT
            id,
            cat,
            subcat,
            MAINTENANCE
        FROM bronze.erp_PX_CAT_G1V2;

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : silver.erp_PX_CAT_G1V2';
        PRINT '>> Load Duration  : '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR)
            + ' seconds';

        PRINT '......................';


        /*======================================================================
            SILVER LAYER COMPLETED
        ======================================================================*/

        PRINT ' ';
        PRINT '==================================================';
        PRINT 'SILVER LAYER LOADING COMPLETED';
        PRINT '==================================================';

        SET @batch_end_time = GETDATE();

        PRINT 'Total Batch Duration : '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR)
            + ' seconds';

        PRINT '==================================================';


    END TRY

    BEGIN CATCH

        PRINT ' ';
        PRINT '==================================================';
        PRINT 'ERROR OCCURRED DURING LOADING SILVER LAYER';
        PRINT '==================================================';

        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State   : ' + CAST(ERROR_STATE() AS NVARCHAR);

        PRINT '==================================================';

    END CATCH;

END;
