--Standardize data format
USE [Portfolio_SQL Data Cleaning]
GO
SELECT * FROM dbo.NashvilleHousing

--Solution_1: COVNERT
UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)
SELECT * FROM dbo.NashvilleHousing

--Solution_2:ADD column then CONVERT
ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
SELECT * FROM dbo.NashvilleHousing

--------------------------------------------------------------------

--Populate Property address data
SELECT PropertyAddress
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

--Solution: JOIN same table
--Identify NULL and data to replace it with
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing AS a
JOIN [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Populate NULL data
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing AS a
JOIN [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------

--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing

--Solution_1: Using SUBSTRING and CHARINDEX
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing

ALTER TABLE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)
UPDATE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
ADD PropertySplitCity Nvarchar(255)
UPDATE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing

--Solution_2: Using PARSENAME
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing

ALTER TABLE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
ADD OwnerSplitState Nvarchar(255)
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing


--------------------------------------------------------------------

--Change Y and N to Yes and No in “Sold as Vacant” field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--------------------------------------------------------------------

--Remove duplicates
--Using CTE, ROW_NUMBER, OVER, PARTITION BY
WITH RowNumCTE AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
)
--SELECT *
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

--------------------------------------------------------------------

--Delete unused columns
SELECT * FROM [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing

ALTER TABLE [Portfolio_SQL Data Cleaning].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate