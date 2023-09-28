SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  --cleaning data in SQL queries

  select *
  from PortfolioProject..NashvilleHousing

  --standardize Date format

    select SaleDateConverted, CONVERT(date,SaleDate)
  from PortfolioProject..NashvilleHousing


update NashvilleHousing
set SaleDate =  CONVERT(date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted =  CONVERT(date,SaleDate)

--Populate property address

select *
 from PortfolioProject..NashvilleHousing
 order by ParcelID

 select a.ParcelID, a.PropertyAddress, b. ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
 from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null

 update a
 set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
  from PortfolioProject..NashvilleHousing a
 join PortfolioProject..NashvilleHousing b
 on a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 where a.PropertyAddress is null


 --Breaking out Address into Individual columns (Address, city, state)

 
select PropertyAddress
 from PortfolioProject..NashvilleHousing
--order by 

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 



ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) 
 


select *
from PortfolioProject..NashvilleHousing




select OwnerAddress
from PortfolioProject..NashvilleHousing


select
PARSENAME(replace(OwnerAddress, ',', '.') , 3)
,PARSENAME(replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(replace(OwnerAddress, ',', '.') , 1)
from PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') , 1)




select *
from PortfolioProject..NashvilleHousing


--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2




select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		else SoldAsVacant
		END
from PortfolioProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		else SoldAsVacant
		END


-- Remove Duplicates
WITH RowNumCTE AS (
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				PropertyAddress,
				Saleprice,
				SaleDate,
				LegalReference
				order by 
				UniqueID
				) row_num
from PortfolioProject..NashvilleHousing
--order by ParcelID
)
delete
FROM RowNumCTE
WHERE row_num > 1
--order by PropertyAddress 



--Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

Alter table PortfolioProject..NashvilleHousing
DROP COLUMN	OwnerAddress, TaxDistrict, PropertyAddress

Alter table PortfolioProject..NashvilleHousing
DROP COLUMN	SaleDate