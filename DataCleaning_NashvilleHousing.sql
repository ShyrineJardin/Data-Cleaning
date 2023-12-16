-- Cleaning Data in Nashville Housing ---

SELECT *
FROM Data_Cleaning..NashvilleHousing

-- Standardize Date Format -------------------------------------------------------------------------

SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Data_Cleaning..NashvilleHousing

UPDATE NashvilleHousing     -- if doesnt work
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing -- use this, then run the  first query to check if it works
ADD SaleDateConverted Date;
UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


--Populate Property Address data ----------------------------------------------------------------------------
SELECT *
FROM Data_Cleaning..NashvilleHousing
--WHERE PropertyAddress is null
ORDER By ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress)
FROM Data_Cleaning..NashvilleHousing a
JOIN Data_Cleaning..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]  <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --ISNULL check the value of a.PropertyAddress if null and if so, it will populate by the value of b.PropertyAddress
FROM Data_Cleaning..NashvilleHousing a
JOIN Data_Cleaning..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]  <> b.[UniqueID ]
WHERE a.PropertyAddress is null


--Breaking out Address Into Individual Columns (address, City, State) --------------------------------------------------------

--For Property Address
SELECT PropertyAddress
FROM Data_Cleaning..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, -- -1  deletes the comma at the end of the word
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as CITY
FROM Data_Cleaning..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Varchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) -- -1  deletes the comma at the end of the word

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Varchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

--For Owners Address
SELECT OwnerAddress
FROM Data_Cleaning..NashvilleHousing

SELECT --ParseName is same as SubString but easier
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3), --ParseName works backwards so in 3 columns 3=1, 2=2, 3=1
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM Data_Cleaning..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Varchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM Data_Cleaning..NashvilleHousing


--Change Y and N to Yes and NO in 'Sold as Vacant'Field --------------------------------------------------------------------------
SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM Data_Cleaning..NashvilleHousing
GROUP BY SoldAsVacant
Order by 2

SELECT SoldAsVacant,
	CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Data_Cleaning..NashvilleHousing

Update NashvilleHousing --UPDATE statement doesnt make a new column for newly update values but just update the existing column unlike ALTER
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates ---------------------------------------------------------------------------------------
-- Note: it is not a good practice to remove from the original table, as much as possible make CTE, temp table and likes

--CTE--
WITH RowNumCTE AS(
Select *,
 ROW_NUMBER() OVER(
 PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY
			UniqueID
 )row_num
From Data_Cleaning..NashvilleHousing
--ORDER BY ParcelID
)

--DELETE  -- run to delete duplicate data
--From RowNumCTE
--WHERE row_num >1

SELECT *
From RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress


--Delete Unused Columns
SELECT *
From Data_Cleaning..NashvilleHousing

ALTER Table Data_Cleaning..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

ALTER Table Data_Cleaning..NashvilleHousing
DROP Column SaleDate

