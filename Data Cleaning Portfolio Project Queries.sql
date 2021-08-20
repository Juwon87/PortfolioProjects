
--Cleaning Data in SQL Queries

SELECT * 
FROM Portfolioproject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM Portfolioproject.dbo.NashvilleHousing

ALTER Table NashvilleHousing
ADD SaleDateConverted date;


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date,SaleDate)



--------------------------------------------------------------------------------------------------------------------------



-- Populate Property Address data



SELECT *
FROM Portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress IS null
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolioproject.dbo.NashvilleHousing a
JOIN Portfolioproject.dbo.NashvilleHousing b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM Portfolioproject.dbo.NashvilleHousing
--WHERE PropertyAddress IS null
--ORDER BY ParcelID


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) AS Address
FROM Portfolioproject.dbo.NashvilleHousing



ALTER Table NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )



ALTER Table NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))




SELECT ownerAddress
FROM Portfolioproject.dbo.NashvilleHousing



SELECT
PARSENAME(REPLACE(ownerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(ownerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(ownerAddress, ',', '.') , 1)
FROM Portfolioproject.dbo.NashvilleHousing






ALTER Table NashvilleHousing
ADD ownerSplitAddress NVARCHAR(255);


UPDATE NashvilleHousing
SET ownerSplitAddress = PARSENAME(REPLACE(ownerAddress, ',', '.') , 3)



ALTER Table NashvilleHousing
ADD ownerSplitCity NVARCHAR(255);


UPDATE NashvilleHousing
SET ownerSplitCity = PARSENAME(REPLACE(ownerAddress, ',', '.') , 2)


ALTER Table NashvilleHousing
ADD ownerSplitState NVARCHAR(255);


UPDATE NashvilleHousing
SET ownerSplitState  = PARSENAME(REPLACE(ownerAddress, ',', '.') , 1)


SELECT *
FROM Portfolioproject.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------



-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolioproject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM Portfolioproject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END



--------------------------------------------------------------------------------------------------------------------------



-- Remove Duplicates


WITH RowNumCTE AS(
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
 
FROM Portfolioproject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress



--------------------------------------------------------------------------------------------------------------------------



-- Delete Unused Columns


SELECT *
FROM Portfolioproject.dbo.NashvilleHousing

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE Portfolioproject.dbo.NashvilleHousing
DROP COLUMN SaleDate