/*==============================================================================
Procedure Name : bronze.load_bronze
Purpose        : Load raw CRM and ERP datasets into the Bronze layer.
Layer          : Bronze
Project        : Data Warehouse & Analytics Project

Description:
    This procedure truncates Bronze tables, loads source CSV files by using
    BULK INSERT, validates loaded row counts, and prints execution logs for
    monitoring and troubleshooting.

parameters:
    This stored procedure doesn't accept any parameters or return any values.

Usuage Example: 
    EXEXC bronze.load_bronze;
==============================================================================*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
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
        PRINT 'Loading Bronze Layer';
        PRINT '==========================================';
        PRINT ' ';

        PRINT '-------------------------';
        PRINT '|  1-LOADING CRM TABLES  |';
        PRINT '-------------------------';
        PRINT ' ';

        /*--------------------------------------------------------------------------
            1.1 CRM Customer Information
        --------------------------------------------------------------------------*/
        PRINT '1.1. Loading customer information table';
        PRINT '        ------------------            ';
        PRINT '>> Truncating Table : bronze.crm_cust_info';
        PRINT '>> Loading File     : cust_info.csv';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Materiales\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : bronze.crm_cust_info';
        PRINT '>> Load Duration  : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '>> Validating Row Count';

        DECLARE @csv_cust_count INT = 18494;
        DECLARE @db_cust_count  INT;

        SELECT @db_cust_count = COUNT(*)
        FROM bronze.crm_cust_info;

        IF @csv_cust_count != @db_cust_count
        BEGIN
            RAISERROR
            (
                'Row count mismatch. Expected: %d | Actual: %d',
                16,
                1,
                @csv_cust_count,
                @db_cust_count
            );
        END
        ELSE
        BEGIN
            PRINT CONCAT(N'✅ Validation passed: ', @db_cust_count, ' of ', CAST(@csv_cust_count AS VARCHAR), ' rows loaded');
        END;

        PRINT '......................';

        /*--------------------------------------------------------------------------
            1.2 CRM Product Information
        --------------------------------------------------------------------------*/
        PRINT ' ';
        PRINT '1.2. Loading product information table';
        PRINT '        ------------------            ';
        PRINT '>> Truncating Table : bronze.crm_prd_info';
        PRINT '>> Loading File     : prd_info.csv';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Materiales\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : bronze.crm_prd_info';
        PRINT '>> Load Duration  : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '>> Validating Row Count';

        DECLARE @csv_prd_count INT = 397;
        DECLARE @db_prd_count  INT;

        SELECT @db_prd_count = COUNT(*)
        FROM bronze.crm_prd_info;

        IF @csv_prd_count != @db_prd_count
        BEGIN
            RAISERROR
            (
                'Row count mismatch. Expected: %d | Actual: %d',
                16,
                1,
                @csv_prd_count,
                @db_prd_count
            );
        END
        ELSE
        BEGIN
            PRINT CONCAT(N'✅ Validation passed: ', @db_prd_count, ' of ', CAST(@csv_prd_count AS VARCHAR), ' rows loaded');
        END;

        PRINT '......................';

        /*--------------------------------------------------------------------------
            1.3 CRM Sales Details
        --------------------------------------------------------------------------*/
        PRINT ' ';
        PRINT '1.3. Loading sales details table';
        PRINT '       ------------------            ';
        PRINT '>> Truncating Table : bronze.crm_sales_details';
        PRINT '>> Loading File     : sales_details.csv';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Materiales\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : bronze.crm_sales_details';
        PRINT '>> Load Duration  : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '>> Validating Row Count';

        DECLARE @csv_sls_count INT = 60398;
        DECLARE @db_sls_count  INT;

        SELECT @db_sls_count = COUNT(*)
        FROM bronze.crm_sales_details;

        IF @csv_sls_count != @db_sls_count
        BEGIN
            RAISERROR
            (
                'Row count mismatch. Expected: %d | Actual: %d',
                16,
                1,
                @csv_sls_count,
                @db_sls_count
            );
        END
        ELSE
        BEGIN
            PRINT CONCAT(N'✅ Validation passed: ', @db_sls_count, ' of ', CAST(@csv_sls_count AS VARCHAR), ' rows loaded');
        END;

        PRINT '......................';

        PRINT ' ';
        PRINT '-------------------------';
        PRINT '|  2-LOADING ERP TABLES  |';
        PRINT '-------------------------';

        /*--------------------------------------------------------------------------
            2.1 ERP Customer Personal Information
        --------------------------------------------------------------------------*/
        PRINT ' ';
        PRINT '2.1. Loading customer personal information table';
        PRINT '           ------------------            ';
        PRINT '>> Truncating Table : bronze.erp_CUST_AZ12';
        PRINT '>> Loading File     : CUST_AZ12.csv';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_CUST_AZ12;

        BULK INSERT bronze.erp_CUST_AZ12
        FROM 'C:\Materiales\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a', -- Handle Windows-style line endings
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : bronze.erp_CUST_AZ12';
        PRINT '>> Load Duration  : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '>> Validating Row Count';

        DECLARE @csv_erp_cust_count INT = 18484;
        DECLARE @db_erp_cust_count  INT;

        SELECT @db_erp_cust_count = COUNT(*)
        FROM bronze.erp_CUST_AZ12;

        IF @csv_erp_cust_count != @db_erp_cust_count
        BEGIN
            RAISERROR
            (
                'Row count mismatch. Expected: %d | Actual: %d',
                16,
                1,
                @csv_erp_cust_count,
                @db_erp_cust_count
            );
        END
        ELSE
        BEGIN
            PRINT CONCAT(N'✅ Validation passed: ', @db_erp_cust_count, ' of ', CAST(@csv_erp_cust_count AS VARCHAR), ' rows loaded');
        END;

        PRINT '......................';

        /*--------------------------------------------------------------------------
            2.2 ERP Location
        --------------------------------------------------------------------------*/
        PRINT ' ';
        PRINT '2.2. Loading location table';
        PRINT '     ------------------      ';
        PRINT '>> Truncating Table : bronze.erp_LOC_A101';
        PRINT '>> Loading File     : LOC_A101.csv';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_LOC_A101;

        BULK INSERT bronze.erp_LOC_A101
        FROM 'C:\Materiales\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : bronze.erp_LOC_A101';
        PRINT '>> Load Duration  : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '>> Validating Row Count';

        DECLARE @csv_loc_count INT = 18484;
        DECLARE @db_loc_count  INT;

        SELECT @db_loc_count = COUNT(*)
        FROM bronze.erp_LOC_A101;

        IF @csv_loc_count != @db_loc_count
        BEGIN
            RAISERROR
            (
                'Row count mismatch. Expected: %d | Actual: %d',
                16,
                1,
                @csv_loc_count,
                @db_loc_count
            );
        END
        ELSE
        BEGIN
            PRINT CONCAT(N'✅ Validation passed: ', @db_loc_count, ' of ', CAST(@csv_loc_count AS VARCHAR), ' rows loaded');
        END;

        PRINT '......................';

        /*--------------------------------------------------------------------------
            2.3 ERP Product Category
        --------------------------------------------------------------------------*/
        PRINT ' ';
        PRINT '2.3. Loading product category table';
        PRINT '        ------------------            ';
        PRINT '>> Truncating Table : bronze.erp_PX_CAT_G1V2';
        PRINT '>> Loading File     : PX_CAT_G1V2.csv';

        SET @start_time = GETDATE();

        TRUNCATE TABLE bronze.erp_PX_CAT_G1V2;

        BULK INSERT bronze.erp_PX_CAT_G1V2
        FROM 'C:\Materiales\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH
        (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();

        PRINT '>> Load Completed : bronze.erp_PX_CAT_G1V2';
        PRINT '>> Load Duration  : ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS VARCHAR) + ' seconds';
        PRINT '>> Validating Row Count';

        DECLARE @csv_px_count INT = 37;
        DECLARE @db_px_count  INT;

        SELECT @db_px_count = COUNT(*)
        FROM bronze.erp_PX_CAT_G1V2;

        IF @csv_px_count != @db_px_count
        BEGIN
            RAISERROR
            (
                'Row count mismatch. Expected: %d | Actual: %d',
                16,
                1,
                @csv_px_count,
                @db_px_count
            );
        END
        ELSE
        BEGIN
            PRINT CONCAT(N'✅ Validation passed: ', @db_px_count, ' of ', CAST(@csv_px_count AS VARCHAR), ' rows loaded');
        END;

        PRINT '......................';
        PRINT ' ';
        PRINT '==================================================';
        PRINT 'BRONZE LAYER LOADING COMPLETED';
        PRINT '==================================================';

        SET @batch_end_time = GETDATE();

        PRINT 'Total Batch Duration : ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + ' seconds';
    END TRY
    BEGIN CATCH
        PRINT '================================================';
        PRINT 'Error occurred during loading Bronze layer';
        PRINT 'Error Message : ' + ERROR_MESSAGE();
        PRINT 'Error Line    : ' + CAST(ERROR_LINE() AS NVARCHAR);
        PRINT 'Error Number  : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State   : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================================';
    END CATCH;
END;
