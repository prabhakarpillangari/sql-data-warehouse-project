/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs various quality checks for data consistency, accuracy, 
    and standardization across the 'silver' layer. It includes checks for:
    - Null or duplicate primary keys.
    - Unwanted spaces in string fields.
    - Data standardization and consistency.
    - Invalid date ranges and orders.
    - Data consistency between related fields.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================
-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results


   ----------------------- bronze check -----------------------------


--Check for NULLS or Duplicates in Primary Key
-- Expectation: No Result

select 
cst_id, count(*)
from bronze.crm_cust_info
group by cst_id 
having cst_id is null or COUNT(*)>1


--Check for unwanted spaces
-- Expectation: No Result
SELECT cst_firstname
from bronze.crm_cust_info
where cst_firstname <> LTRIM(RTRIM(cst_firstname))

SELECT cst_lastname
from bronze.crm_cust_info
where cst_lastname <> LTRIM(RTRIM(cst_lastname))

SELECT cst_gndr
from bronze.crm_cust_info
where cst_gndr <> LTRIM(RTRIM(cst_gndr))

-- Data standardization & Consistency 
SELECT distinct cst_gndr from 
bronze.crm_cust_info

SELECT distinct cst_marital_status from 
bronze.crm_cust_info


   -----------------------silver check-----------------------------

select 
cst_id, count(*)
from silver.crm_cust_info
group by cst_id 
having cst_id is null or COUNT(*)>1


--Check for unwanted spaces
-- Expectation: No Result
SELECT cst_firstname
from silver.crm_cust_info
where cst_firstname <> LTRIM(RTRIM(cst_firstname))

SELECT cst_lastname
from bronze.crm_cust_info
where cst_lastname <> LTRIM(RTRIM(cst_lastname))

SELECT cst_gndr
from silver.crm_cust_info
where cst_gndr <> LTRIM(RTRIM(cst_gndr))

-- Data standardization & Consistency 
SELECT distinct cst_gndr from 
silver.crm_cust_info

SELECT distinct cst_marital_status from 
silver.crm_cust_info

print '--------------------------------------------------------------------------------------------'


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

   -----------------------bronze check-----------------------------

--primary key null value check 

select prd_id, count(*)x from 
bronze.crm_prd_info
group by prd_id
having count(*) >1 or prd_id is null


--check unwanted spaces 
--Expectation : no result

select * from 
bronze.crm_prd_info
where prd_key <> LTRIM(RTRIM(prd_key))

--Data standardization & consistency
select DISTINCT prd_line from bronze.crm_prd_info

-- CHECK for Invalid Date Orders
select *
from bronze.crm_prd_info
where prd_end_dt < prd_start_dt

select *
from bronze.crm_prd_info


   -----------------------silver check-----------------------------
--primary key null value check 


select prd_id, count(*)x from 
silver.crm_prd_info
group by prd_id
having count(*) >1 or prd_id is null


--check unwanted spaces 
--Expectation : no result

select * from 
silver.crm_prd_info
where prd_key <> LTRIM(RTRIM(prd_key))

--Data standardization & consistency
select DISTINCT prd_line from silver.crm_prd_info

-- CHECK for Invalid Date Orders
select *
from silver.crm_prd_info
where prd_end_dt < prd_start_dt

select *
from silver.crm_prd_info

print '--------------------------------------------------------------------------------------'
-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================


----------------BRONZE CHECK----------------------------

select * from bronze.crm_sales_details
where sls_cust_id is null or sls_cust_id < 0


select * from bronze.crm_sales_details
where sls_prd_key is null

select 
	sls_ord_num, 
	sls_prd_key, 
	sls_cust_id, 
	sls_order_dt, 
	sls_ship_dt,
	sls_due_dt, 
	sls_sales, 
	sls_quantity, 
	sls_price
from bronze.crm_sales_details
where sls_ord_num  <> LTRIM(RTRIM(sls_ord_num))


select 
	*
from bronze.crm_sales_details
where sls_prd_key not in (
select prd_key from silver.crm_prd_info)

select *
from bronze.crm_sales_details
where sls_cust_id not in (
select cst_id from silver.crm_cust_info)

---check for invalid dates


SELECT NULLIF(sls_due_dt,0) AS sls_order_dt 
FROM bronze.crm_sales_details
WHERE  sls_due_dt <= 0 OR 
	   LEN(sls_due_dt) <> 8 OR  
	   sls_due_dt > 20500101 OR 
	   sls_due_dt < 19000101


SELECT * FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_order_dt OR sls_ship_dt > sls_due_dt

--> CHECK DATA consistency: between sales, qunatity and price
--> sales = quantity * price
--> values must not be NULL, zero or negative.



SELECT DISTINCT
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price,
CASE WHEN sls_sales IS NULL  OR sls_sales  <= 0 OR sls_sales <> sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0
	 THEN sls_sales / sls_quantity
	ELSE sls_price
END AS sls_price
from bronze.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
OR sls_price <=0 OR sls_quantity <=0 OR sls_sales <=0
ORDER BY sls_sales , sls_quantity, sls_price 


-----------------------SILVER CHECK-----------------------

select * from silver.crm_sales_details
where sls_cust_id is null or sls_cust_id < 0


select * from silver.crm_sales_details
where sls_prd_key is null

select 
	sls_ord_num, 
	sls_prd_key, 
	sls_cust_id, 
	sls_order_dt, 
	sls_ship_dt,
	sls_due_dt, 
	sls_sales, 
	sls_quantity, 
	sls_price
from silver.crm_sales_details
where sls_ord_num  <> LTRIM(RTRIM(sls_ord_num))


select 
	*
from silver.crm_sales_details
where sls_prd_key not in (
select prd_key from silver.crm_prd_info)

select *
from silver.crm_sales_details
where sls_cust_id not in (
select cst_id from silver.crm_cust_info)

---check for invalid dates


SELECT NULLIF(sls_due_dt,0) AS sls_order_dt 
FROM silver.crm_sales_details
WHERE  sls_due_dt <= 0 OR 
	   LEN(sls_due_dt) <> 8 OR  
	   sls_due_dt > 20500101 OR 
	   sls_due_dt < 19000101


SELECT * FROM silver.crm_sales_details
WHERE sls_order_dt > sls_order_dt OR sls_ship_dt > sls_due_dt

--> CHECK DATA consistency: between sales, qunatity and price
--> sales = quantity * price
--> values must not be NULL, zero or negative.



SELECT DISTINCT
sls_sales as old_sls_sales,
sls_quantity,
sls_price as old_sls_price,
CASE WHEN sls_sales IS NULL  OR sls_sales  <= 0 OR sls_sales <> sls_quantity * ABS(sls_price)
	 THEN sls_quantity * ABS(sls_price)
	ELSE sls_sales
END AS sls_sales,
CASE WHEN sls_price IS NULL OR sls_price <= 0
	 THEN sls_sales / NULLIF(sls_quantity,0)
	ELSE sls_price
END AS sls_price
from silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
OR sls_price <=0 OR sls_quantity <=0 OR sls_sales <=0
ORDER BY sls_sales , sls_quantity, sls_price 


select * from silver.crm_sales_details


print '--------------------------------------------------------------------------------------'

-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

----------------- bronze----------------------

select 
CASE WHEN cid LIKE  'NAS%' THEN SUBSTRING(cid,4,len(cid))
	ELSE cid
END cid,
bdate,
gen
from bronze.erp_cust_az12
where CASE WHEN cid LIKE  'NAS%' THEN SUBSTRING(cid,4,len(cid))
	ELSE cid
END not in (
SELECT DISTINCT cst_key FROM silver.crm_cust_info)

--CHECK BDATE OUT OF RANGES
SELECT bdate FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
ORDER BY 1 ASC


--data standardization & consistency
select distinct gen,
CASE WHEN UPPER(LTRIM(RTRIM(gen))) IN ('F','FEMALE') THEN 'Female'
	 WHEN UPPER(LTRIM(RTRIM(gen))) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END as gen
from 
bronze.erp_cust_az12


------------------------silver --------------------------
select 
CASE WHEN cid LIKE  'NAS%' THEN SUBSTRING(cid,4,len(cid))
	ELSE cid
END cid,
bdate,
gen
from silver.erp_cust_az12
where CASE WHEN cid LIKE  'NAS%' THEN SUBSTRING(cid,4,len(cid))
	ELSE cid
END not in (
SELECT DISTINCT cst_key FROM silver.crm_cust_info)

--CHECK BDATE OUT OF RANGES
SELECT bdate FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE()
ORDER BY 1 ASC


--data standardization & consistency
select distinct gen,
CASE WHEN UPPER(LTRIM(RTRIM(gen))) IN ('F','FEMALE') THEN 'Female'
	 WHEN UPPER(LTRIM(RTRIM(gen))) IN ('M','MALE') THEN 'Male'
	 ELSE 'n/a'
END as gen
from 
silver.erp_cust_az12

print '--------------------------------------------------------------------------------------'

-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================


---------------bronze-----------------
select 
cid,
REPLACE(cid, '-','') as cid,
cntry
from bronze.erp_loc_a101
where REPLACE(cid, '-','')  not in (select cst_key from silver.crm_cust_info)



select distinct cntry,
CASE  WHEN LTRIM(RTRIM(cntry)) = 'DE' THEN 'Germany'
	  WHEN LTRIM(RTRIM(cntry)) IN ('US','USA') THEN 'United States'
	  WHEN LTRIM(RTRIM(cntry)) = '' OR  cntry  IS NULL THEN 'n/a'
	  ELSE LTRIM(RTRIM(cntry))
END cntry
from bronze.erp_loc_a101

---------------silver-----------------

select 
cid,
REPLACE(cid, '-','') as cid,
cntry
from silver.erp_loc_a101
where REPLACE(cid, '-','')  not in (select cst_key from silver.crm_cust_info)



select distinct cntry,
CASE  WHEN LTRIM(RTRIM(cntry)) = 'DE' THEN 'Germany'
	  WHEN LTRIM(RTRIM(cntry)) IN ('US','USA') THEN 'United States'
	  WHEN LTRIM(RTRIM(cntry)) = '' OR  cntry  IS NULL THEN 'n/a'
	  ELSE LTRIM(RTRIM(cntry))
END cntry
from silver.erp_loc_a101


print '--------------------------------------------------------------------------------------'

-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

--------------------------------Bronze  -------------------
select  
id as cat_id,
cat,
subcat,
maintenance
from bronze.erp_px_cat_g1v2
where id not in (

select cat_id from silver.crm_prd_info)

--check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat <> LTRIM(RTRIM(cat)) or subcat <> LTRIM(RTRIM(subcat)) or maintenance <> LTRIM(RTRIM(maintenance))

--data standardization or consistency

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2

SELECT * FROM bronze.erp_px_cat_g1v2


--------------------------------silver ---------------------------------------

select  
id as cat_id,
cat,
subcat,
maintenance
from silver.erp_px_cat_g1v2
where id not in (

select cat_id from silver.crm_prd_info)

--check for unwanted spaces
SELECT * FROM silver.erp_px_cat_g1v2
WHERE cat <> LTRIM(RTRIM(cat)) or subcat <> LTRIM(RTRIM(subcat)) or maintenance <> LTRIM(RTRIM(maintenance))

--data standardization or consistency

SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2

SELECT * FROM silver.erp_px_cat_g1v2



















