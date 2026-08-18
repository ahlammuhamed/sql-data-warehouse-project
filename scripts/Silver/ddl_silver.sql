  -- =============================================================
  -- Create Silver Layer Tables -- Database : DataWarehouse 
  -- Schema : Silver -- Created : [17 Agust 2026] 
  -- Description: This script creates the raw/staging tables in the Silver layer for both CRM and ERP source systems. 
  -- Existing tables are dropped and recreated. 
  -- =============================================================


  -- ------------------------------------------------------------- 
  -- CRM Tables (Customer Relationship Management) 
  -- ------------------------------------------------------------- 
  -- Table: Silver.crm_cust_info 
  -- Description: Stores raw customer demographic and profile data 
  -- -------------------------------------------------------------
if object_id ('silver.crm_cust_info', 'U') is not null 
 drop table silver.crm_cust_info;

create table silver.crm_cust_info
(
	cus_id int,
	cst_key nvarchar(50) ,
	cst_firstname nvarchar(50),
	cst_lastname nvarchar(50),
	cst_marital_status varchar(15),
	cst_gndr varchar(15),
	cst_create_date date,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: silver.crm_prd_info
-- Description: Stores raw product catalog and pricing information
-- -------------------------------------------------------------
if object_id ('silver.crm_prd_info', 'U') is not null 
 drop table silver.crm_prd_info;
create table silver.crm_prd_info
(
	prd_id int,
	cat_id NVARCHAR(50),
	prd_key nvarchar(50) ,
	prd_nm nvarchar(50),
	prd_cost int ,
	prd_line nvarchar(50),
	prd_start_dt DATE ,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()

);
GO

-- Table: silver.crm_sales_details
-- Description: Stores raw sales transactions and order line details
-- -------------------------------------------------------------
if object_id ('silver.crm_sales_details', 'U') is not null 
 drop table silver.crm_sales_details;

create table silver.crm_sales_details
(
	sls_ord_num nvarchar(50),
	sls_prd_key nvarchar(50) ,
	sls_cust_id int,
	sls_order_dt DATE ,
	sls_ship_dt DATE ,
	sls_due_dt DATE,
	sls_sales int,
	sls_quantity int ,
	sls_price int,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO


-- -------------------------------------------------------------
-- ERP Tables (Enterprise Resource Planning)
-- -------------------------------------------------------------

-- Table: silver.erp_CUST_AZ12
-- Description: Stores raw customer birthdate and gender from ERP
-- -------------------------------------------------------------
if object_id ('silver.erp_CUST_AZ12', 'U') is not null 
 drop table silver.erp_CUST_AZ12;
create table silver.erp_CUST_AZ12
(
	CID nvarchar(50),
	BDATE date ,
	GEN nvarchar(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: silver.erp_LOC_A101
-- Description: Stores raw customer location and country data from ERP
-- -------------------------------------------------------------
if object_id ('silver.erp_LOC_A101', 'U') is not null 
 drop table silver.erp_LOC_A101;
create table silver.erp_LOC_A101
(
	CID nvarchar(50),
	CNTRY nvarchar(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

-- Table: silver.erp_PX_CAT_G1V2
-- Description: Stores raw product category and subcategory data from ERP
-- -------------------------------------------------------------
if object_id ('silver.erp_PX_CAT_G1V2', 'U') is not null 
 drop table silver.erp_PX_CAT_G1V2;
create table silver.erp_PX_CAT_G1V2
(
	ID nvarchar(50),
	CAT nvarchar(50) ,
	SUBCAT nvarchar(50),
	MAINTENANCE NVARCHAR(10),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO
