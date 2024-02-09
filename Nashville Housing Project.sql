--Cleaning Data in SQL

SELECT *
FROM Housing..NashvilleHousing

---Standardize date format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Housing..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Housing..NashvilleHousing


---Property Address data

SELECT *
FROM Housing..NashvilleHousing 
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing..NashvilleHousing a
JOIN Housing..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Housing..NashvilleHousing a
JOIN Housing..NashvilleHousing b
    ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking Address into individual coloumns(City, State)

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City

FROM Housing..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD NewPropertyAddress Nvarchar(255);

UPDATE NashvilleHousing
SET NewPropertyAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE NashvilleHousing
ADD NewPropertyCity Nvarchar(255);

UPDATE NashvilleHousing
SET NewPropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))




SELECT OwnerAddress
FROM Housing..NashvilleHousing


SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Housing..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD NewOwneraddress Nvarchar(255);

UPDATE NashvilleHousing
SET NewOwneraddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD NewOwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET NewOwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD NewOwnerState Nvarchar(255);

UPDATE NashvilleHousing
SET NewOwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--REplacing Y and N with Yes and No
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Housing..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Housing..NashvilleHousing
 

 UPDATE NashvilleHousing
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
   ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
	
FROM Housing..NashvilleHousing
--ORDER BY ParcelID
)
DELETE  
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Column

ALTER TABLE Housing..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

SELECT *
FROM Housing..NashvilleHousing