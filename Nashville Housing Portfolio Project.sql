
--DATA CLEANING

select *
from PortfolioProject..NashvilleHousing

-- Standardizing Sales Date

select SaleDate, convert(Date, SaleDate) as SaleDateFormated
from PortfolioProject..NashvilleHousing

alter table NashvilleHousing
add SaleDateFormated Date

update NashvilleHousing
set SaleDateFormated = convert(Date, SaleDate)


select SaleDateFormated
from PortfolioProject..NashvilleHousing


--Populating the Property Address Data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.propertyaddress, b.PropertyAddress) as UpdatedPropertyAddress
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = isnull(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null

--Breaking out Address into Individual Columns(Address, City, State)


select *
from PortfolioProject..NashvilleHousing
order by PropertyAddress

select PropertyAddress,
substring(PropertyAddress, 1, charindex(',', propertyaddress)-1) as Address,
substring(PropertyAddress, charindex(',', propertyaddress)+1, charindex(',', propertyaddress)) as City-- LEN(propertyaddress)) as City
from NashvilleHousing

		--	OR

--select PropertyAddress,
--parsename(replace(propertyaddress, ',', '.'), 2),
--parsename(replace(propertyaddress, ',', '.'), 1)
--from NashvilleHousing


update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', propertyaddress)-1)

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', propertyaddress)+1, charindex(',', propertyaddress))

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

select OwnerAddress,
PARSENAME(replace(owneraddress, ',','.'),3),
PARSENAME(replace(owneraddress, ',','.'),2),
PARSENAME(replace(owneraddress, ',','.'),1)
from NashvilleHousing
where OwnerAddress is not null

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',','.'),3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',','.'),2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',','.'),1)

-- Change Y and N to Yes and No in "Sold as vacant" field

select SoldAsVacant, count(soldasvacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant,
case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end
from NashvilleHousing

Update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'Y' then 'Yes'
	else SoldAsVacant
	end


--REMOVING DUPLICATES

with RowNumCTE as(
select *,
	row_number() over(
	partition by
		ParcelID,
		PropertyAddress,
		SalePrice,
		LegalReference
		order by
			uniqueid
			) as Row_Num
from NashvilleHousing
)
select *
from RowNumCTE
where Row_Num > 1

--DELETING UNUSED COLUMNS

Alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from PortfolioProject..NashvilleHousing


