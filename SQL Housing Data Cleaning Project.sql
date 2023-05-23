/****** Script for SelectTopNRows command from SSMS  ******/
SELECT * 
FROM [Nashville Housing]


-- Standardize Sale Date

Select SaleDateConverted
FROM [Nashville Housing]

UPDATE [Nashville Housing]
SET SaleDate = CONVERT(date,SaleDate)

-- Above not working, will try alter table method

ALTER TABLE [Nashville Housing]
ADD SaleDateConverted Date;

UPDATE [Nashville Housing]
SET SaleDateConverted = CONVERT(date, SaleDate)

Select SaleDateConverted
FROM [Nashville Housing]


-- Property Address Data, some addresses are null

SELECT *
FROM [Nashville Housing]
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a
SET propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM [Nashville Housing] a
JOIN [Nashville Housing] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT *
FROM [Nashville Housing]
WHERE PropertyAddress is null


-- Breaking out address into city and state

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City
FROM [Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE [Nashville Housing]
ADD PropertySplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM [Nashville Housing]


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM [Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState Nvarchar(255);

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

SELECT *
FROM [Nashville Housing]


-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [Nashville Housing]


UPDATE [Nashville Housing]
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



--Remove Duplicates

WITH RowNumCTE AS (
Select *, 
ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER BY UniqueID
	) row_num
FROM [Nashville Housing]
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM [Nashville Housing]


--Delete Unused Columns

ALTER TABLE [Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Nashville Housing]
DROP COLUMN SaleDate