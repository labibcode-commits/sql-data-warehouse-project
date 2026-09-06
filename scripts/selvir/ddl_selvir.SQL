print '===================================';
print '>>Truncate the table : selvir.crm_cust_info ';
TRUNCATE TABLE selvir.crm_cust_info;
print '===================================';

INSERT INTO selvir.crm_cust_info (
    cst_id ,
    cst_key ,
    cst_firstname ,
    cst_lastname ,
    cst_marital_status ,
    cst_gndr ,
    cst_create_date
)
select cst_id,
cst_key,
TRIM(cst_firstname) cst_firstname,
TRIM(cst_lastname) cst_lastname,
case when cst_marital_status = 'S' then 'Single'
    when cst_marital_status = 'M' then 'Married'
    else 'NONE'
    end,

case when cst_gndr = 'F' then 'Female'
    when cst_gndr = 'M' then 'Male'
    else 'NONE'
    end
cst_gndr,
cst_create_date
from (select *,
    ROW_NUMBER() over(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag
    FROM bronze.crm_cust_info
)t
where flag =1 and cst_id is NOT NULL;

print '===================================';
print '>>Truncate the table : selvir.crm_prd_info ';
TRUNCATE TABLE selvir.crm_prd_info;
print '===================================';

INSERT INTO selvir.crm_prd_info(
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt)
SELECT
 prd_id 
 ,
replace(substring(prd_key,1,5),'-','_') as cat_id,
substring(prd_key,7,LEN(prd_key)) as prd_key


,prd_nm 
,isnull(prd_cost,0) as prd_cost
,CASE 
    WHEN  prd_line = 'M' THEN  'Mountain'
    when prd_line = 'R' then 'Roade'
    WHEN  prd_line = 'S' THEN  'Other Sales'
    WHEN  prd_line = 'T' THEN  ' Touring'
    ELSE 'None' 
END as prd_line
,cast(prd_start_dt as date) as prd_start_dt,
cast(lead(prd_start_dt)over( PARTITION BY prd_key order by prd_start_dt)-1 as date) as prd_end_dt

from bronze.crm_prd_info;

print '===================================';
print '>>Truncate the table : selvir.crm_sales_details ';
TRUNCATE TABLE selvir.crm_sales_details;
print '===================================';

INSERT into selvir.crm_sales_details(
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE 
    WHEN sls_order_dt <=0 or len(sls_order_dt) != 8 THEN  NULL
    ELSE  cast(cast(sls_order_dt as varchar) as date) 
END as sls_order_dt,

cast(cast(sls_ship_dt as varchar)as date) sls_ship_dt,
cast(cast(sls_due_dt as varchar) as date) sls_due_dt,


CASE 
    WHEN sls_sales is NULL or sls_sales<=0 or sls_sales != sls_quantity *abs(sls_price) 
    THEN sls_quantity *abs(sls_price) 
    ELSE  sls_sales
END as sls_sales,
sls_quantity,

CASE 
    WHEN sls_price is NULL or sls_price<=0  
    THEN  sls_sales /NULLif(sls_quantity,0)
    ELSE  sls_sales
END as sls_price
from bronze.crm_sales_details;

print '===================================';
print '>>Truncate the table : selvir.erp_cust_az12 ';
TRUNCATE TABLE selvir.erp_cust_az12;
print '===================================';

INSERT INTO selvir.erp_cust_az12(
    CID,
    BDATE,
    GEN

)
SELECT 

CASE 
    WHEN cid like'NAS%' THEN  SUBSTRING(cid,4,len(cid))
    ELSE  cid
END as cid,

CASE 
    WHEN bdate>getdate() THEN  null
    ELSE  bdate
END as BDATE,


CASE 
    WHEN gen ='F' THEN  'Female'
    when gen = 'M' then 'Male'
    when gen is null or gen ='' then 'none'
    ELSE  gen
END as gen
from bronze.erp_cust_az12;


print '===================================';
print '>>Truncate the table : selvir.erp_loc_a101 ';
TRUNCATE TABLE selvir.erp_loc_a101;
print '===================================';

insert into selvir.erp_loc_a101(
    CID,
    CNTRY
)

SELECT 
stuff(cid,3,1,'') as CID
,CASE 
    WHEN cntry ='DE' THEN  'Germany'
    when cntry in ('US','USA') then 'United States'
    when cntry ='' or cntry is null then 'None'
    ELSE  cntry
END as CNTRY
from bronze.erp_loc_a101;



print '===================================';
print '>>Truncate the table : selvir.erp_px_cat_g1v2 ';
TRUNCATE TABLE selvir.erp_px_cat_g1v2;
print '===================================';

INSERT into selvir.erp_px_cat_g1v2(
   id,
cat,
subcat,
MAINTENANCE 
)

select 
id,
cat,
subcat,
MAINTENANCE
from  bronze.erp_px_cat_g1v2



  
