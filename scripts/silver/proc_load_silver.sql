/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

IF OBJECT_ID('silver.load_silver', 'P') IS NOT NULL
    DROP PROCEDURE silver.load_silver;
GO
CREATE  PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME,  @batch_end_time DATETIME ;
	BEGIN TRY
		SET @batch_start_time = GETDATE()
		PRINT'================================================================';
		PRINT'Loading silver Layer';
		PRINT'================================================================';

		PRINT'----------------------------------------------------------------';
		PRINT'Loading CRM Tables'
		PRINT'----------------------------------------------------------------';
	

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.crm_cust_info';
		TRUNCATE TABLE silver.crm_cust_info
		PRINT '>> Inserting Data into silver.crm_cust_info';

		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date )

		select
		cst_id,
		cst_key,
		LTRIM(RTRIM(cst_firstname)),
		LTRIM(RTRIM(cst_lastname)),
		case when UPPER(LTRIM(RTRIM(cst_marital_status))) ='S' then 'Single'
			 When UPPER(LTRIM(RTRIM(cst_marital_status))) ='M' then 'Married'
			 else 'n/a'
		end cst_marital_status,
		case when UPPER(LTRIM(RTRIM(cst_gndr))) ='M' then 'Male'
			 When UPPER(LTRIM(RTRIM(cst_gndr))) ='F' then 'Female'
			 else 'n/a'
		end cst_gndr,
		cst_create_date
		From (
			select 
			*,
			Row_number()  over(partition by cst_id order by cst_create_date desc) as flag_last
			from bronze.crm_cust_info
			where cst_id is not null
		)t where flag_last = 1  ;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds';
		PRINT'--------------------'

		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.crm_prd_info';
		TRUNCATE TABLE silver.crm_prd_info
		PRINT '>> Inserting Data into silver.crm_prd_info';

		Insert into silver.crm_prd_info(
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
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
			prd_nm,
			ISNULL(prd_cost,0) as prd_cost,
			CASE UPPER(LTRIM(RTRIM(prd_line)))
				WHEN  'M' then 'Mountain'
				WHEN  'S' then 'Other Sales'
				WHEN  'R' then 'Road'
				WHEN  'T' then 'Touring'
				ELSE 'n/a'
			END	prd_line,
			CAST(prd_start_dt as date) as prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER(partition by prd_key order by prd_start_dt) - 1 as date) as prd_end_dt
		  FROM bronze.crm_prd_info 
		  SET @end_time = GETDATE();
		  PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds';
		  PRINT'--------------------'






		SET @start_time = GETDATE();

		PRINT '>> TRUNCATING TABLE: silver.crm_sales_details';
		TRUNCATE TABLE silver.crm_sales_details
		PRINT '>> Inserting Data into silver.crm_sales_details';

		INSERT INTO SILVER.crm_sales_details (
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
		select 
			sls_ord_num, 
			sls_prd_key, 
			sls_cust_id, 
			CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
				 ELSE CAST(CAST(sls_order_dt AS varchar) AS DATE)
			END sls_order_dt,
			CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) <> 8 THEN NULL
				 ELSE CAST(CAST(sls_ship_dt AS varchar) AS DATE)
			END sls_ship_dt,
			CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
				 ELSE CAST(CAST(sls_due_dt AS varchar) AS DATE)
			END sls_due_dt,
			CASE WHEN sls_sales IS NULL  OR sls_sales  <= 0 OR sls_sales <> sls_quantity * ABS(sls_price)
				 THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, 
			sls_quantity, 
			CASE WHEN sls_price IS NULL OR sls_price <= 0
				THEN sls_sales / NULLIF(sls_quantity,0)
				ELSE sls_price
			END AS sls_price
		from bronze.crm_sales_details
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds';
		PRINT'--------------------'


		PRINT'----------------------------------------------------------------';
		PRINT'Loading ERP Tables'
		PRINT'----------------------------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.erp_cust_az12';
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT '>> Inserting Data into silver.erp_cust_az12';


		Insert into silver.erp_cust_az12 (cid,bdate,gen)
		select 
		CASE WHEN cid LIKE  'NAS%' THEN SUBSTRING(cid,4,len(cid))
			ELSE cid
		END cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
		END as bdate,
		CASE WHEN UPPER(LTRIM(RTRIM(gen))) IN ('F','FEMALE') THEN 'Female'
			 WHEN UPPER(LTRIM(RTRIM(gen))) IN ('M','MALE') THEN 'Male'
			 ELSE 'n/a'
		END gen
		from bronze.erp_cust_az12
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds';
		PRINT'--------------------'


		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.erp_loc_a101';
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT '>> Inserting Data into silver.erp_loc_a101';

		INSERT INTO silver.erp_loc_a101 (cid,cntry)

		select 
		REPLACE(cid, '-','') as cid,
		CASE  WHEN LTRIM(RTRIM(cntry)) = 'DE' THEN 'Germany'
			  WHEN LTRIM(RTRIM(cntry)) IN ('US','USA') THEN 'United States'
			  WHEN LTRIM(RTRIM(cntry)) = '' OR  cntry  IS NULL THEN 'n/a'
			  ELSE LTRIM(RTRIM(cntry))
		END cntry
		from bronze.erp_loc_a101
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds';
		PRINT'--------------------'


		SET @start_time = GETDATE();
		PRINT '>> TRUNCATING TABLE: silver.erp_px_cat_g1v2';
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT '>> Inserting Data into silver.erp_px_cat_g1v2';

		INSERT INTO silver.erp_px_cat_g1v2 (id,cat,subcat,maintenance)
		select  
		id as cat_id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST (DATEDIFF(second,@start_time,@end_time) as NVARCHAR) + ' seconds';
		PRINT'--------------------'


		SET @batch_end_time = GETDATE()
		PRINT'======================================'
		PRINT 'Loading silver Layer is Completed'
		PRINT '    -Total Load Duration: '+ CAST (DATEDIFF(second,@batch_start_time,@batch_end_time) as NVARCHAR) + ' seconds';
		PRINT'======================================'
	END TRY
	BEGIN CATCH
		PRINT '====================================================='
		PRINT 'ERROR OCCURED DURING SILVER LAYER'
		PRINT 'ERROR Message' + ERROR_MESSAGE();
		PRINT 'ERROR Message' + CAST (ERROR_NUMBER() AS NVARCHAR);
		PRINT 'ERROR Message' + CAST (ERROR_STATE() AS NVARCHAR);
		PRINT '====================================================='
	END CATCH

END


