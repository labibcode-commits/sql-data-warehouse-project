IF EXISTS (select 1 from sys.database Where name = 'Datawarehouse')
BEGIN
    AFTER DATABASE Datawarehouse set SINGLE_USER WITH ROLLBACK IMMEDIATE
    DROP DATABASE Datewarehouse
END;
GO

CREATE DATABASE DateWareHouse;
use DateWareHouse;
CREATE SCHEMA bronze;
go
CREATE SCHEMA selvir;
go
CREATE SCHEMA gold;


#
if OBJECT_ID( 'bronze.crm_cust_info','U'  ) is not NULL
    DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE);
if OBJECT_ID( 'bronze.crm_prd_info','U'  ) is not NULL
    DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id INT,	
    prd_key	NVARCHAR(50),
    prd_nm NVARCHAR(50),	
    prd_cost INT,	
    prd_line NVARCHAR(50),	
    prd_start_dt DATETIME,	
    prd_end_dt DATETIME

);


if OBJECT_ID( 'bronze.crm_sales_details','U'  ) is not NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,	
    sls_order_dt INT,	
    sls_ship_dt INT,	
    sls_due_dt INT,	
    sls_sales INT,	
    sls_quantity INT,	
    sls_price INT

);
if OBJECT_ID( 'bronze.erp_cust_az12','U'  ) is not NULL
    DROP TABLE bronze.erp_cust_az12;
CREATE Table bronze.erp_cust_az12 (
    CID NVARCHAR(50),	
    BDATE date,	
    GEN NVARCHAR(50)

);
if OBJECT_ID( 'bronze.erp_loc_a101','U'  ) is not NULL
    DROP TABLE bronze.erp_loc_a101;
CREATE Table bronze.erp_loc_a101 (
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50)

);
if OBJECT_ID( 'bronze.erp_px_cat_g1v2','U'  ) is not NULL
    DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50)
);
