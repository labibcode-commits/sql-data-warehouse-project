if OBJECT_ID( 'selvir.crm_cust_info','U'  ) is not NULL
    DROP TABLE selvir.crm_cust_info;
CREATE TABLE selvir.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE);
if OBJECT_ID( 'selvir.crm_prd_info','U'  ) is not NULL
    DROP TABLE selvir.crm_prd_info;
CREATE TABLE selvir.crm_prd_info (
    prd_id INT,	
    prd_key	NVARCHAR(50),
    prd_nm NVARCHAR(50),	
    prd_cost INT,	
    prd_line NVARCHAR(50),	
    prd_start_dt DATETIME,	
    prd_end_dt DATETIME

);


if OBJECT_ID( 'selvir.crm_sales_details','U'  ) is not NULL
    DROP TABLE selvir.crm_sales_details;

CREATE TABLE selvir.crm_sales_details (
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
if OBJECT_ID( 'selvir.erp_cust_az12','U'  ) is not NULL
    DROP TABLE selvir.erp_cust_az12;
CREATE Table selvir.erp_cust_az12 (
    CID NVARCHAR(50),	
    BDATE date,	
    GEN NVARCHAR(50)

);
if OBJECT_ID( 'selvir.erp_loc_a101','U'  ) is not NULL
    DROP TABLE selvir.erp_loc_a101;
CREATE Table selvir.erp_loc_a101 (
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50)

);
if OBJECT_ID( 'selvir.erp_px_cat_g1v2','U'  ) is not NULL
    DROP TABLE selvir.erp_px_cat_g1v2;
CREATE TABLE selvir.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50)
);


