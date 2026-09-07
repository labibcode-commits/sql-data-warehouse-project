if OBJECT_ID( 'gold.dim_customers','v'  ) is not NULL
    DROP view gold.dim_customers;
go


CREATE VIEW gold.dim_customers as

SELECT 
    ROW_NUMBER() over(ORDER BY cst_id) as customer_key,

    ci.cst_id as customer_id,
    ci.cst_key as customer_number,
    ci.cst_firstname as first_name,
    ci.cst_lastname last_name,
    lo.CNTRY as country,
    CASE 
        WHEN ci.cst_gndr !='None' THEN ci.cst_gndr 
        ELSE  coalesce(ca.gen,'None')
    END as gender,
    ci.cst_marital_status as marital_status,
    
    ca.BDATE as birth_date,
    ci.cst_create_date as create_date 
   
    

from selvir.crm_cust_info ci
LEFT join selvir.erp_cust_az12 ca
on ci.cst_key = ca.CID
LEFT JOIN selvir.erp_loc_a101 lo
on  ci.cst_key = lo.CID
go


if OBJECT_ID( 'gold.fact_sales','v'  ) is not NULL
    DROP view gold.fact_sales;
go

CREATE VIEW gold.fact_sales as 
SELECT 
    sd.sls_ord_num as order_number,
    pr.product_key ,
    
    cu.customer_key,
    
    sd.sls_order_dt as order_date,
    sd.sls_ship_dt as shipping_date,
    sd.sls_due_dt as due_date,
    sd.sls_sales as sales_amount,
    sd.sls_quantity as quantiy,
    sd.sls_price
from selvir.crm_sales_details sd
left join gold.dim_products pr
on sd.sls_prd_key = pr.product_number
left join gold.dim_customers cu
on sd.sls_cust_id = cu.customer_id 
go



if OBJECT_ID( 'gold.dim_products','v'  ) is not NULL
    DROP view gold.dim_products;
go


create VIEW gold.dim_products as

SELECT
    ROW_NUMBER() over(ORDER BY pr.prd_start_dt ,pr.prd_key)as product_key,
    pr.prd_id as product_id,
    pr.prd_key as product_number,
    pr.prd_nm as product_name,
    pr.cat_id as category_id,
    pc.cat as category ,
    pc.SUBCAT as subcategory,
    pc.MAINTENANCE,
    pr.prd_cost as cost,
    pr.prd_line as product_line,
    pr.prd_start_dt as start_date
from selvir.crm_prd_info pr
LEFT JOIN selvir.erp_px_cat_g1v2 pc
on pc.id = pr.cat_id
where pr.prd_end_dt is null
