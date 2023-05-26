--Cleaning Data in SQL Queries

select * 
from 
NashvilleHousing



-- Standardize Date Format

select SaleDateConvert ,convert(Date, SaleDate)
from 
NashvilleHousing


alter table NashvilleHousing
Add SaleDateConvert Date; 

Update NashvilleHousing
set SaleDateConvert = CONVERT (Date, SaleDate)



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select a.ParcelId, a.PropertyAddress, b.ParcelId, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)

from 
NashvilleHousing a

join NashvilleHousing b 
    on a.ParcelId = b.ParcelId
    and a.[UniqueID] <> b.[UniqueId]
where a.PropertyAddress is null

update a 
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from 
NashvilleHousing a

join NashvilleHousing b 
    on a.ParcelId = b.ParcelId
    and a.[UniqueID] <> b.[UniqueId]
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from 
NashvilleHousing


select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 ) as address 

, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , len(PropertyAddress)) as address 

from 
NashvilleHousing
--order by Address


alter table NashvilleHousing
Add PropertySplitAddress varchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1 )



alter table NashvilleHousing
Add PropertySplitCity varchar (255); 

UPDATE NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1 , len(PropertyAddress))

SELECT * 
FROM NashvilleHousing


select OwnerAddress
from NashvilleHousing


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from NashvilleHousing


alter table NashvilleHousing
Add OwnerSplitAddress varchar (255); 

UPDATE NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


alter table NashvilleHousing
Add OwnerSplitCity varchar (255); 

UPDATE NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


alter table NashvilleHousing
Add OwnerSplitState varchar (255); 

UPDATE NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * 
FROM NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT (SoldAsVacant), count(SoldAsVacant)
FROM NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant= 'N' THEN 'No'
	 else SoldAsVacant
end

FROM NashvilleHousing


update NashvilleHousing
set  SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'Yes'
     when SoldAsVacant= 'N' THEN 'No'
	 else SoldAsVacant
	 end


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE AS (
select *,  
row_number() over (
partition by  ParcelId,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  order by UniqueID
			  ) row_num
FROM NashvilleHousing)

SELECT *
from RowNumCTE 
where row_num > 1 
order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate