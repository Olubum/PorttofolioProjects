SELECT TOP 10 * FROM PortfolioProject.dbo.NashvilleHousing

--Data Cleaning

--Standardize SaleDate

SELECT CAST(SaleDate AS DATE) FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing -- This update didn't work, so i'll just alter the table
SET SaleDate= CAST(SaleDate AS DATE)

ALTER TABLE NashvilleHousing
ADD SaleDate2 DATE

UPDATE NashvilleHousing
SET SaleDate2 =CAST(SaleDate AS DATE)


--Populate PropertyAddress  data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON  a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON  a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out Address into individual columns (Address, State, City)

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address
FROM NashvilleHousing

SELECT SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashvilleHousing

-- Add columns to host the split address data
ALTER TABLE NashvilleHousing
ADD PropertyUpdatedAddress NVARCHAR (250)

UPDATE NashvilleHousing
SET PropertyUpdatedAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertyCity NVARCHAR (250)

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Splitting OwnerAddress into Address/City/State

SELECT PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR (250)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerCity NVARCHAR (250)

UPDATE NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerState NVARCHAR (250)

UPDATE NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- Change N to No and Y to Yes in the Sold as Vacant Column
SELECT DISTINCT(Soldasvacant) 
FROM NashvilleHousing

SELECT CASE WHEN Soldasvacant = 'N' THEN 'No'
WHEN Soldasvacant ='Y' THEN 'YES'
ELSE Soldasvacant END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN Soldasvacant = 'N' THEN 'No'
WHEN Soldasvacant ='Y' THEN 'YES'
ELSE Soldasvacant END 


--Remove Duplicate
WITH RowNumCTE AS
(SELECT *, 
  ROW_NUMBER() 
  OVER( PARTITION BY ParcelID,
                     PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 ORDER BY UniqueID
					 ) Row_Num
FROM NashvilleHousing)

SELECT * 
FROM RowNumCTE
WHERE Row_Num >1


--Delete unused columns
SELECT * FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
