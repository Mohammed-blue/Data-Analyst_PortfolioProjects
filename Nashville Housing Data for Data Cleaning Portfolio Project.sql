/*

Cleaning Data in SQL Queries

*/

SELECT 
    uniqueID,
    ParcelID,
    LandUse,
    PropertyAddress,
    SaleDate,
    SalePrice,
    LegalReference,
    SoldAsVacant,
    OwnerAddress,
    Acreage,
    TaxDistrict,
    LandValue,
    BuildingValue,
    TotalValue,
    YearBuilt,
    Bedrooms,
    FullBath,
    HalfBath
FROM
    nashvillehousingdatafordatacleaning
LIMIT 1000;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT 
    SaleDate, STR_TO_DATE(SaleDate, '%M %e, %Y') AS ConvertedSaleDate
FROM
    nashvillehousingdatafordatacleaning;

UPDATE nashvillehousingdatafordatacleaning 
SET 
    SaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

SELECT 
    SaleDate
FROM
    nashvillehousingdatafordatacleaning;


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT 
    *
FROM
    nashvillehousingdatafordatacleaning
ORDER BY ParcelID;

SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    COALESCE(NULLIF(a.PropertyAddress, ''),
            b.PropertyAddress) AS MergedPropertyAddress
FROM
    nashvillehousingdatafordatacleaning a
        JOIN
    nashvillehousingdatafordatacleaning b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID
WHERE
    a.propertyAddress = '';
    
UPDATE nashvillehousingdatafordatacleaning a
        JOIN
    nashvillehousingdatafordatacleaning b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID 
SET 
    a.PropertyAddress = COALESCE(NULLIF(a.PropertyAddress, ''),
            b.PropertyAddress)
WHERE
    a.PropertyAddress = '';
    

    

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT 
    PropertyAddress
FROM
    nashvillehousingdatafordatacleaning;
-- ORDER BY ParcelID;

SELECT 
    SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress)) AS Address
FROM
    nashvillehousingdatafordatacleaning;

ALTER TABLE nashvillehousingdatafordatacleaning
ADD PropertySplitAddress CHAR(255);

UPDATE nashvillehousingdatafordatacleaning 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1);
        
ALTER TABLE nashvillehousingdatafordatacleaning
ADD PropertySplitCity CHAR(255);

UPDATE nashvillehousingdatafordatacleaning 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress));

SELECT 
    *
FROM
    nashvillehousingdatafordatacleaning;


SELECT 
    OwnerAddress
FROM
    nashvillehousingdatafordatacleaning;

SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),
            ',',
            - 1) AS StreetAddress,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1) AS City,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),
            ',',
            - 1) AS State
FROM
    nashvillehousingdatafordatacleaning;


ALTER TABLE nashvillehousingdatafordatacleaning
ADD OwnerSplitAddress CHAR(255);

UPDATE nashvillehousingdatafordatacleaning 
SET 
    OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),
            ',',
            - 1);

ALTER TABLE nashvillehousingdatafordatacleaning
ADD OwnerSplitCity CHAR(255);

UPDATE nashvillehousingdatafordatacleaning 
SET 
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);
        
ALTER TABLE nashvillehousingdatafordatacleaning
ADD OwnerSplitState CHAR(255);

UPDATE nashvillehousingdatafordatacleaning 
SET 
    OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),
            ',',
            - 1);

SELECT 
    *
FROM
    nashvillehousingdatafordatacleaning;



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    nashvillehousingdatafordatacleaning
GROUP BY SoldAsVacant
order by 2;


SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM
    nashvillehousingdatafordatacleaning;
    
UPDATE nashvillehousingdatafordatacleaning 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
SELECT 
    *,
    ROW_NUMBER() OVER (
    PARTITION BY 
		ParcelID, 
        PropertyAddress, 
        SalePrice,
		SaleDate,
		LegalReference
		ORDER BY UniqueID
        ) row_num
FROM
    nashvillehousingdatafordatacleaning
    -- ORDER BY ParcelID;
    )
DELETE nashvillehousingdatafordatacleaning
FROM nashvillehousingdatafordatacleaning
JOIN RowNumCTE ON nashvillehousingdatafordatacleaning.UniqueID = RowNumCTE.UniqueID
WHERE RowNumCTE.row_num > 1;

SELECT 
	*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
SELECT 
    *
FROM
    nashvillehousingdatafordatacleaning;


ALTER TABLE nashvillehousingdatafordatacleaning
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict, 
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
