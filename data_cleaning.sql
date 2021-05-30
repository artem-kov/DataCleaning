/*

Cleaning Data with MySQL 

Data set: Nashville Housing Data

*/

SELECT
	*
FROM
	data_cleaning_project.nashville_housing

------------------------------------------------------------------------------------------

-- Standardize Date format

SELECT
	SaleDate, STR_TO_DATE(SaleDate, "%d-%b-%y")
FROM
	data_cleaning_project.nashville_housing


UPDATE
	data_cleaning_project.nashville_housing
SET
	SaleDate = STR_TO_DATE(SaleDate, "%d-%b-%y")


-- In case previous previous update query does not change the table
	
-- ALTER TABLE data_cleaning_project.nashville_housing
-- CHANGE COLUMN SaleDate SaleDate DATE


------------------------------------------------------------------------------------------

-- Populating Property Address 

UPDATE
	data_cleaning_project.nashville_housing
SET
	PropertyAddress = NULL 
WHERE 
	LENGTH(PropertyAddress) = 0

	
SELECT
	* 
FROM
	data_cleaning_project.nashville_housing
-- WHERE 
-- 	PropertyAddress IS NULL
ORDER BY 
	ParcelID 
	

SELECT 	
	nh1.ParcelID, nh1.PropertyAddress,
	nh2.ParcelID, nh2.PropertyAddress,
	IFNULL(nh1.PropertyAddress, nh2.PropertyAddress) 
FROM 
	data_cleaning_project.nashville_housing nh1 
	JOIN data_cleaning_project.nashville_housing nh2 
	ON nh1.ParcelID = nh2.ParcelID AND
	nh1.UniqueID <> nh2.UniqueID 
WHERE 
	nh1.PropertyAddress IS NULL


UPDATE
	data_cleaning_project.nashville_housing nh1
	JOIN data_cleaning_project.nashville_housing nh2 
	ON nh1.ParcelID = nh2.ParcelID AND
	nh1.UniqueID <> nh2.UniqueID 
SET
	nh1.PropertyAddress = IFNULL(nh1.PropertyAddress, nh2.PropertyAddress)
WHERE 
	nh1.PropertyAddress IS NULL

	
------------------------------------------------------------------------------------------
	
-- Dividing Address into Address, City, State columns

SELECT 
	PropertyAddress 
FROM 
	data_cleaning_project.nashville_housing 


SELECT
	SUBSTRING_INDEX(PropertyAddress, ',', 1) as Address,
	SUBSTRING_INDEX(PropertyAddress, ',', -1) as City
FROM 
	data_cleaning_project.nashville_housing 
	

ALTER TABLE data_cleaning_project.nashville_housing 
ADD COLUMN PropertyAddressSplit VARCHAR(255) AFTER PropertyAddress


UPDATE
	data_cleaning_project.nashville_housing
SET
	PropertyAddressSplit = SUBSTRING_INDEX(PropertyAddress, ',', 1)


ALTER TABLE data_cleaning_project.nashville_housing 
ADD COLUMN PropertyCitySplit VARCHAR(255) AFTER PropertyAddressSplit


UPDATE
	data_cleaning_project.nashville_housing
SET
	PropertyCitySplit = SUBSTRING_INDEX(PropertyAddress, ',', -1)
	



SELECT
	*
FROM
	data_cleaning_project.nashville_housing




SELECT
	OwnerAddress
FROM
	data_cleaning_project.nashville_housing


UPDATE
	data_cleaning_project.nashville_housing
SET
	OwnerAddress = NULL 
WHERE 
	LENGTH(OwnerAddress) = 0	
	



SELECT
	SUBSTRING_INDEX(OwnerAddress, ',', 1) as OwnerAddressSplit,
	SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) as OwnerCitySplit,
	SUBSTRING_INDEX(OwnerAddress, ',', -1) as OwnerStateSplit
FROM 
	data_cleaning_project.nashville_housing



	
ALTER TABLE data_cleaning_project.nashville_housing 
ADD COLUMN OwnerAddressSplit VARCHAR(255) AFTER OwnerAddress


UPDATE
	data_cleaning_project.nashville_housing
SET
	OwnerAddressSplit = SUBSTRING_INDEX(OwnerAddress, ',', 1)


ALTER TABLE data_cleaning_project.nashville_housing 
ADD COLUMN OwnerCitySplit VARCHAR(255) AFTER OwnerAddressSplit


UPDATE
	data_cleaning_project.nashville_housing
SET
	OwnerCitySplit = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)


ALTER TABLE data_cleaning_project.nashville_housing 
ADD COLUMN OwnerStateSplit VARCHAR(255) AFTER OwnerCitySplit


UPDATE
	data_cleaning_project.nashville_housing
SET
	OwnerStateSplit = SUBSTRING_INDEX(OwnerAddress, ',', -1)


SELECT 
	*
FROM 
	data_cleaning_project.nashville_housing 
	

------------------------------------------------------------------------------------------

-- Change Y and N values in "SoldAsVacant" to Yes and No


SELECT 
	DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM 
	data_cleaning_project.nashville_housing
GROUP BY
	SoldAsVacant 
ORDER BY 
	2	
	

SELECT 
	SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM 
	data_cleaning_project.nashville_housing


UPDATE data_cleaning_project.nashville_housing
SET SoldAsVacant = 
		CASE 
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			WHEN SoldAsVacant = 'N' THEN 'No'
			ELSE SoldAsVacant
			END
	
	
------------------------------------------------------------------------------------------

-- Remove duplicates

WITH row_count_cte AS (
SELECT 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress,
				 SalePrice,
				 LegalReference
				 ORDER BY 
				 	UniqueID 
				) as row_count
FROM 
	data_cleaning_project.nashville_housing 
ORDER BY 
	ParcelID)	
SELECT 
	*
FROM
	row_count_cte
WHERE 
	row_count = 1 
ORDER BY 
	ParcelID 
 
	
------------------------------------------------------------------------------------------

-- Remove unused columns
	
	
ALTER TABLE data_cleaning_project.nashville_housing
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress

