CREATE OR ALTER PROCEDURE selvir.LOAD_selvir AS
BEGIN
    BEGIN TRY
        PRINT '===================================';
        PRINT '>> Truncate table: selvir.crm_cust_info';
        PRINT '===================================';
        TRUNCATE TABLE selvir.crm_cust_info;

        -- Process: Load crm_cust_info from Bronze to Silver
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
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE 
                WHEN cst_marital_status = 'S' THEN 'Single'
                WHEN cst_marital_status = 'M' THEN 'Married'
                ELSE 'None'
            END AS cst_marital_status,
            CASE 
                WHEN cst_gndr = 'F' THEN 'Female'
                WHEN cst_gndr = 'M' THEN 'Male'
                ELSE 'None'
            END AS cst_gndr,
            cst_create_date
        FROM (
            SELECT *,
                ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag
            FROM bronze.crm_cust_info
        ) t
        WHERE flag = 1 AND cst_id IS NOT NULL;


        PRINT '===================================';
        PRINT '>> Truncate table: selvir.crm_prd_info';
        PRINT '===================================';
        TRUNCATE TABLE selvir.crm_prd_info;

        -- Process: Load crm_prd_info from Bronze to Silver
        INSERT INTO selvir.crm_prd_info (
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
            TRIM(prd_nm) AS prd_nm, 
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE 
                WHEN prd_line = 'M' THEN 'Mountain'
                WHEN prd_line = 'R' THEN 'Road'
                WHEN prd_line = 'S' THEN 'Other Sales'
                WHEN prd_line = 'T' THEN 'Touring'
                ELSE 'None' 
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            DATEADD(day, -1, CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) AS DATE)) AS prd_end_dt
        FROM bronze.crm_prd_info;


        PRINT '===================================';
        PRINT '>> Truncate table: selvir.crm_sales_details';
        PRINT '===================================';
        TRUNCATE TABLE selvir.crm_sales_details;

        -- Process: Load crm_sales_details from Bronze to Silver
        INSERT INTO selvir.crm_sales_details (
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
                WHEN sls_order_dt <= 0 OR LEN(CAST(sls_order_dt AS VARCHAR(10))) != 8 THEN NULL
                ELSE CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112) 
            END AS sls_order_dt,

            CASE 
                WHEN sls_ship_dt <= 0 OR LEN(CAST(sls_ship_dt AS VARCHAR(10))) != 8 THEN NULL
                ELSE CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)), 112) 
            END AS sls_ship_dt,

            CASE 
                WHEN sls_due_dt <= 0 OR LEN(CAST(sls_due_dt AS VARCHAR(10))) != 8 THEN NULL
                ELSE CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)), 112) 
            END AS sls_due_dt,

            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
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


        PRINT '===================================';
        PRINT '>> Truncate table: selvir.erp_cust_az12';
        PRINT '===================================';
        TRUNCATE TABLE selvir.erp_cust_az12;

        -- Process: Load erp_cust_az12 from Bronze to Silver
        INSERT INTO selvir.erp_cust_az12 (
            CID,
            BDATE,
            GEN
        )
        SELECT 
            CASE 
                WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS BDATE,

            CASE 
                WHEN gen = 'F' THEN 'Female'
                WHEN gen = 'M' THEN 'Male'
                WHEN gen IS NULL OR TRIM(gen) = '' THEN 'None'
                ELSE gen
            END AS gen
        FROM bronze.erp_cust_az12;


        PRINT '===================================';
        PRINT '>> Truncate table: selvir.erp_loc_a101';
        PRINT '===================================';
        TRUNCATE TABLE selvir.erp_loc_a101;

        -- Process: Load erp_loc_a101 from Bronze to Silver
        INSERT INTO selvir.erp_loc_a101 (
            CID,
            CNTRY
        )
        SELECT 
            STUFF(cid, 3, 1, '') AS CID,
            CASE 
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'None'
                ELSE TRIM(cntry)
            END AS CNTRY
        FROM bronze.erp_loc_a101;


        PRINT '===================================';
        PRINT '>> Truncate table: selvir.erp_px_cat_g1v2';
        PRINT '===================================';
        TRUNCATE TABLE selvir.erp_px_cat_g1v2;

        -- Process: Load erp_px_cat_g1v2 from Bronze to Silver
        INSERT INTO selvir.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            MAINTENANCE
        )
        SELECT 
            id,
            TRIM(cat) AS cat,
            TRIM(subcat) AS subcat,
            MAINTENANCE
        FROM bronze.erp_px_cat_g1v2;

    END TRY 
    BEGIN CATCH
        PRINT 'There was an error during loading the data.';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
    END CATCH
END;
