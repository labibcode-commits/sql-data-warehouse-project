print '===================================';
print '>>Truncate the table : selvir.crm_cust_info ';
TRUNCATE TABLE selvir.crm_cust_info;
print '===================================';

-- ==============================================================================
-- Process: Load crm_cust_info from Bronze to Silver
-- Objective: Standardize customer names, marital status, and gender.
-- Deduplication Strategy: Keep the most recent record per customer based on cst_create_date.
-- ==============================================================================
INSERT INTO selvir.crm_cust_info (
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
)
SELECT 
    cst_id,
    cst_key,
    -- Clean leading/trailing spaces from names
    TRIM(cst_firstname) as cst_firstname,
    TRIM(cst_lastname) as cst_lastname,
    
    -- Standardize Marital Status values
    CASE 
        WHEN cst_marital_status = 'S' THEN 'Single'
        WHEN cst_marital_status = 'M' THEN 'Married'
        ELSE 'None'
    END as cst_marital_status,
    
    -- Standardize Gender values
    CASE 
        WHEN cst_gndr = 'F' THEN 'Female'
        WHEN cst_gndr = 'M' THEN 'Male'
        ELSE 'None'
    END as cst_gndr,
    cst_create_date
FROM (
    -- Window function to identify duplicates and rank them by creation date (descending)
    SELECT *,
    ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) as flag
    FROM bronze.crm_cust_info
) t
-- Filter out duplicates (keep only the latest record) and ignore NULL customer IDs
WHERE flag = 1 AND cst_id IS NOT NULL;


print '===================================';
print '>>Truncate the table : selvir.crm_prd_info ';
TRUNCATE TABLE selvir.crm_prd_info;
print '===================================';

-- ==============================================================================
-- Process: Load crm_prd_info from Bronze to Silver
-- Objective: Clean product keys, standardize product lines, and calculate valid date ranges (SCD Type 2 logic).
-- ==============================================================================
INSERT INTO selvir.crm_prd_info(
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
    -- Extract category ID from product key and replace hyphen with underscore
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') as cat_id,
    -- Extract the actual product key starting from the 7th character
    SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
    TRIM(prd_nm) as prd_nm, 
    
    -- Handle NULL costs by defaulting to 0
    ISNULL(prd_cost, 0) as prd_cost,
    
    -- Map product line codes to descriptive text
    CASE 
        WHEN prd_line = 'M' THEN 'Mountain'
        WHEN prd_line = 'R' THEN 'Road'
        WHEN prd_line = 'S' THEN 'Other Sales'
        WHEN prd_line = 'T' THEN 'Touring'
        ELSE 'None' 
    END as prd_line,
    
    CAST(prd_start_dt AS DATE) as prd_start_dt,
    
    -- Calculate prd_end_dt by taking the start date of the NEXT record for the same product minus 1 day
    DATEADD(day, -1, CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE)) as prd_end_dt
FROM bronze.crm_prd_info;


print '===================================';
print '>>Truncate the table : selvir.crm_sales_details ';
TRUNCATE TABLE selvir.crm_sales_details;
print '===================================';

-- ==============================================================================
-- Process: Load crm_sales_details from Bronze to Silver
-- Objective: Validate date formats, calculate missing sales metrics, and ensure data integrity.
-- ==============================================================================
INSERT INTO selvir.crm_sales_details(
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
    
    -- Validate and format Order Date (YYYYMMDD to DATE). Set invalid/zero dates to NULL.
    CASE 
        WHEN sls_order_dt <= 0 OR LEN(CAST(sls_order_dt AS VARCHAR(10))) != 8 THEN NULL
        ELSE CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112) 
    END as sls_order_dt,

    -- Validate and format Shipping Date
    CASE 
        WHEN sls_ship_dt <= 0 OR LEN(CAST(sls_ship_dt AS VARCHAR(10))) != 8 THEN NULL
        ELSE CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)), 112) 
    END as sls_ship_dt,

    -- Validate and format Due Date
    CASE 
        WHEN sls_due_dt <= 0 OR LEN(CAST(sls_due_dt AS VARCHAR(10))) != 8 THEN NULL
        ELSE CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)), 112) 
    END as sls_due_dt,

    -- Recalculate Sales Amount if it is NULL, zero, or does not match Quantity * Price
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
        THEN sls_quantity * ABS(sls_price) 
        ELSE sls_sales
    END as sls_sales,
    
    sls_quantity,

    -- Recalculate Price if it is NULL or zero by dividing Sales by Quantity (avoiding divide-by-zero errors)
    CASE 
        WHEN sls_price IS NULL OR sls_price <= 0  
        THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END as sls_price

FROM bronze.crm_sales_details;


print '===================================';
print '>>Truncate the table : selvir.erp_cust_az12 ';
TRUNCATE TABLE selvir.erp_cust_az12;
print '===================================';

-- ==============================================================================
-- Process: Load erp_cust_az12 from Bronze to Silver
-- Objective: Clean ERP customer IDs, validate birthdates, and standardize gender.
-- ==============================================================================
INSERT INTO selvir.erp_cust_az12(
    CID,
    BDATE,
    GEN
)
SELECT 
    -- Remove the 'NAS' prefix from customer IDs if it exists
    CASE 
        WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid
    END as cid,

    -- Invalidate future birthdates (set to NULL)
    CASE 
        WHEN bdate > GETDATE() THEN NULL
        ELSE bdate
    END as BDATE,

    -- Standardize Gender codes to descriptive text
    CASE 
        WHEN gen = 'F' THEN 'Female'
        WHEN gen = 'M' THEN 'Male'
        WHEN gen IS NULL OR TRIM(gen) = '' THEN 'None'
        ELSE gen
    END as gen
FROM bronze.erp_cust_az12;


print '===================================';
print '>>Truncate the table : selvir.erp_loc_a101 ';
TRUNCATE TABLE selvir.erp_loc_a101;
print '===================================';

-- ==============================================================================
-- Process: Load erp_loc_a101 from Bronze to Silver
-- Objective: Reformat location IDs and map country codes to full country names.
-- ==============================================================================
INSERT INTO selvir.erp_loc_a101(
    CID,
    CNTRY
)
SELECT 
    -- Remove the 3rd character (hyphen) from the location ID using STUFF
    STUFF(cid, 3, 1, '') as CID,
    
    -- Map abbreviated country codes to full names and handle empty values
    CASE 
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
        WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'None'
        ELSE TRIM(cntry)
    END as CNTRY
FROM bronze.erp_loc_a101;


print '===================================';
print '>>Truncate the table : selvir.erp_px_cat_g1v2 ';
TRUNCATE TABLE selvir.erp_px_cat_g1v2;
print '===================================';

-- ==============================================================================
-- Process: Load erp_px_cat_g1v2 from Bronze to Silver
-- Objective: Clean text fields by trimming whitespace.
-- ==============================================================================
INSERT INTO selvir.erp_px_cat_g1v2(
    id,
    cat,
    subcat,
    MAINTENANCE 
)
SELECT 
    id,
    -- Clean leading/trailing spaces
    TRIM(cat) as cat,
    TRIM(subcat) as subcat,
    MAINTENANCE
FROM bronze.erp_px_cat_g1v2;
