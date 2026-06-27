-- =============================================================
-- Create Bronze Layer Tables
-- Database  : DataWarehouse
-- Schema    : Bronze
-- Created   : [27 june 2026]
-- Description: This script creates the raw/staging tables in the
--              Bronze layer for both CRM and ERP source systems.
--              Existing tables are dropped and recreated.
-- =============================================================


-- -------------------------------------------------------------
-- CRM Tables (Customer Relationship Management)
-- -------------------------------------------------------------

-- Table: bronze.crm_cust_info
-- Description: Stores raw customer demographic and profile data
-- -------------------------------------------------------------
if object_id ('bronze.crm_cust_info', 'U') is not null 
 drop table bronze.crm_cust_info;

create table bronze.crm_cust_info
(
	cus_id int,
	cst_key nvarchar(50) ,
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status varchar(15),
	cst_gndr varchar(15),
	cst_create_date date
);
GO

-- Table: bronze.crm_prd_info
-- Description: Stores raw product catalog and pricing information
-- -------------------------------------------------------------
if object_id ('bronze.crm_prd_info', 'U') is not null 
 drop table bronze.crm_prd_info;
create table bronze.crm_prd_info
(
	prd_id int,
	prd_key nvarchar(50) ,
	prd_nm nvarchar(50),
	prd_cost int ,
	prd_line nvarchar(50),
	prd_start_dt DATE ,
	prd_end_dt DATE
);
GO

-- Table: bronze.crm_sales_details
-- Description: Stores raw sales transactions and order line details
-- -------------------------------------------------------------
if object_id ('bronze.crm_sales_details', 'U') is not null 
 drop table bronze.crm_sales_details;

create table bronze.crm_sales_details
(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50) ,
	sls_cust_id int,
	sls_order_dt int ,
	sls_ship_dt int ,
	sls_due_dt int,
	sls_sales int,
	sls_quantity int ,
	sls_price int
);
GO


-- -------------------------------------------------------------
-- ERP Tables (Enterprise Resource Planning)
-- -------------------------------------------------------------

-- Table: bronze.erp_CUST_AZ12
-- Description: Stores raw customer birthdate and gender from ERP
-- -------------------------------------------------------------
if object_id ('bronze.erp_CUST_AZ12', 'U') is not null 
 drop table bronze.erp_CUST_AZ12;
create table bronze.erp_CUST_AZ12
(
	CID nvarchar(50),
	BDATE date ,
	GEN nvarchar(50)
);
GO

-- Table: bronze.erp_LOC_A101
-- Description: Stores raw customer location and country data from ERP
-- -------------------------------------------------------------
if object_id ('bronze.erp_LOC_A101', 'U') is not null 
 drop table bronze.erp_LOC_A101;
create table bronze.erp_LOC_A101
(
	CID nvarchar(50),
	CNTRY nvarchar(50) 
);
GO

-- Table: bronze.erp_PX_CAT_G1V2
-- Description: Stores raw product category and subcategory data from ERP
-- -------------------------------------------------------------
if object_id ('bronze.erp_PX_CAT_G1V2', 'U') is not null 
 drop table bronze.erp_PX_CAT_G1V2;
create table bronze.erp_PX_CAT_G1V2
(
	ID nvarchar(50),
	CAT nvarchar(50) ,
	SUBCAT nvarchar(50),
	MAINTENANCE NVARCHAR(10) 
);
GO
