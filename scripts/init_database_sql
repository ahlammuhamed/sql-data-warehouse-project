/*==============================================================================
 Project      : Data Warehouse Initialization Script
 File         : init_data_warehouse.sql
 Author       : Ahlam
 Environment  : Microsoft SQL Server
================================================================================

 Purpose:
 --------
 This script initializes the Data Warehouse environment by:

   1. Dropping the existing database (if it already exists)
   2. Creating a fresh Data Warehouse database
   3. Creating the required schemas:
        - Bronze   : Raw ingested data layer
        - Silver   : Cleaned and transformed data layer
        - Gold     : Business-ready analytical layer

 Notes:
 ------
 - This script is intended for development and testing environments.
 - The database will be completely deleted and recreated.
 - All existing data inside the target database will be permanently removed.

 Warning:
 --------
 EXECUTING THIS SCRIPT WILL:
   - DROP the existing database
   - DELETE all stored data permanently

 Make sure you have a valid backup before execution.

==============================================================================*/

USE master;
GO

-- Check whether the database already exists
IF EXISTS (
    SELECT *
    FROM sys.databases
    WHERE name = 'data_warehouse'
)
BEGIN

    -- Force all active connections to close immediately
    ALTER DATABASE data_warehouse
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    -- Remove the existing database
    DROP DATABASE data_warehouse;

END;
GO

-- Create a new Data Warehouse database
CREATE DATABASE data_warehouse;
GO

-- Switch context to the newly created database
USE data_warehouse;
GO

/*--------------------------------------------------------------------------
    Create Bronze Schema
    Stores raw data exactly as received from source systems
--------------------------------------------------------------------------*/
CREATE SCHEMA bronze;
GO

/*--------------------------------------------------------------------------
    Create Silver Schema
    Stores cleaned, standardized, and transformed data
--------------------------------------------------------------------------*/
CREATE SCHEMA silver;
GO

/*--------------------------------------------------------------------------
    Create Gold Schema
    Stores business-ready data models for reporting and analytics
--------------------------------------------------------------------------*/
CREATE SCHEMA gold;
GO
