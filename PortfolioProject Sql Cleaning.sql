--cleaning data in sql queries
select *
from PortfolioProject.dbo.Sheet1

--standardize data format
select SaleDateConverted , CONVERT(Date,SaleDate)
from PortfolioProject.dbo.Sheet1
-- This method of upbdating data in the table doesnt always work this is why we will use the second way which is alter table 
UPDATE Sheet1
Set SaleDate = CONVERT(Date,SaleDate)
-- second method
Alter Table sheet1
Add SaleDateConverted Date;
UPDATE Sheet1
Set SaleDateConverted = CONVERT(Date,SaleDate)

--Populate Property Address Data
select *
from PortfolioProject.dbo.Sheet1
where PropertyAddress is Null

-- rn will fix the adress part by filling the ones that are null with data with same parcel ID
select A.ParcelID , A.PropertyAddress , B.ParcelID ,B.PropertyAddress , ISNULL(A.PropertyAddress,B.PropertyAddress)
from PortfolioProject.dbo.Sheet1 A
join PortfolioProject.dbo.Sheet1 B
on A.ParcelID = B.ParcelID
And A.[UniqueID] <> B.[UniqueId]
where A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
from PortfolioProject.dbo.Sheet1 A
join PortfolioProject.dbo.Sheet1 B
on A.ParcelID = B.ParcelID
And A.[UniqueID] <> B.[UniqueId]
where A.PropertyAddress is null

--Breaking out Address Into Individual Columns (Address, City , State)
select PropertyAddress
from PortfolioProject.dbo.Sheet1

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) AS Address

from PortfolioProject.dbo.Sheet1
Alter Table sheet1
Add PropertysplitAddress NVARCHAR(255);
UPDATE Sheet1
Set PropertysplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 
Alter Table sheet1
Add PropertysplitCity NVARCHAR(255);
UPDATE Sheet1
Set PropertysplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress)) 

SELECT OwnerAddress
from PortfolioProject.dbo.Sheet1

select
PARSENAME(Replace(OwnerAddress,',','.'),3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'),1)


from PortfolioProject.dbo.Sheet1
Alter Table sheet1
Add OwnerSplitAddress NVARCHAR(255);
UPDATE Sheet1
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)
Alter Table sheet1
Add OwnerSplitcity NVARCHAR(255);
UPDATE Sheet1
Set OwnerSplitcity = PARSENAME(Replace(OwnerAddress,',','.'),2)

Alter Table sheet1
Add OwnerSplitstate NVARCHAR(255);
UPDATE Sheet1
Set OwnerSplitstate = PARSENAME(Replace(OwnerAddress,',','.'),1)


select *
from PortfolioProject.dbo.Sheet1

--Change Y and N to Yes and No in "Sold As Vacant" field
select Distinct(SoldAsvacant), count(SoldAsvacant)
from PortfolioProject.dbo.Sheet1
group by SoldAsvacant
order by 2


select SoldAsvacant
,CASE WHEN  SoldAsvacant = 'Y' THEN 'Yes'
      WHEN  SoldAsvacant = 'N' THEN 'No'
      Else SoldAsvacant
      End
from PortfolioProject.dbo.Sheet1
update Sheet1
Set SoldAsvacant =CASE WHEN  SoldAsvacant = 'Y' THEN 'Yes'
      WHEN  SoldAsvacant = 'N' THEN 'No'
      Else SoldAsvacant
      End
--Remove Duplicates

With RowNumCTE As(
select * ,
	ROW_NUMBER()OVER(
	PARTITION BY ParcelId,PropertyAddress,SalePrice,SaleDate,LegalReference
	Order By UniqueId
	) ROW_NUM
from PortfolioProject.dbo.Sheet1
--Order By ParcelId
)
DELETE
from RowNumCTE
where row_num >1
--order by UniqueId

--Delete Unused Columns
--Deleting the columns that we did split earlier to make it more visual and eaiser 

select *
from PortfolioProject.dbo.Sheet1
ALTER TABLE PortfolioProject.dbo.Sheet1
DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress
ALTER TABLE PortfolioProject.dbo.Sheet1
DROP COLUMN SaleDate