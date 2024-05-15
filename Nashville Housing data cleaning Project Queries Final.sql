

-------------------------------------------------/* Cleaning Data in SQL Queries */----------------------------------------
USE ProjectsDB;
GO

CREATE PROCEDURE NashvilleH
AS
SELECT * FROM NashvilleHousing

--1. Update the sales date column format from datetime to date
UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

SELECT * FROM NashvilleHousing;
GO


--2. Fill blank "PropertyAddress" cells based on cells which have the same ParcelID AND PropertyAddress and populate the PropertyAddress null cells 

	/* Every row had a ParcelID but not every row had a PropertyAddress. 
		Fortunately every ParcelID which had null value in the Property Address had a duplicate row with both ParcelID and PropertyAddress NOT NULL, 
		so I self joined the table based on ParcelID and UniqueID (row id) to fill the blank cells on PropertyAddress column*/
		

--2.1 Check if there is any null value in PropertyAddress column
SELECT * FROM NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID;
GO

--2.2 Update the column with the Property Address "a" with that of Property Address "b"
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND
a.UniqueID <> b.UniqueID;


--3. Breaking out OwnerAddress into Individual Columns (Address, City, State)

 --3.1 Add Address, City, State columns

ALTER TABLE NashvilleHousing
ADD OwnerStreet VARCHAR(100);

ALTER TABLE NashvilleHousing
ADD OwnerCity VARCHAR(100);

ALTER TABLE NashvilleHousing
ADD OwnerState VARCHAR(10);


 --3.2 Insert data in the previous created columns based on OwnerAddress column
UPDATE NashvilleHousing
SET 
OwnerStreet = 
	SUBSTRING(OwnerAddress, 0, CHARINDEX( ',', OwnerAddress ) ),
OwnerCity = SUBSTRING( 
			OwnerAddress, 
				(CHARINDEX( ',', OwnerAddress) + 1 )  -- starting position from which to take the values.
				, CHARINDEX( ',', OwnerAddress,  ( CHARINDEX( ',', OwnerAddress ) + 1 )) 
				- ( CHARINDEX( ',', OwnerAddress) + 1 )), /* start to search for the second delimiter right after the first delimiter. */
										
OwnerState = SUBSTRING(OwnerAddress, CHARINDEX( ',', OwnerAddress, ( CHARINDEX( ',', OwnerAddress) + 1 ) ) + 1, LEN(OwnerAddress)) /*Length of the column being the number of characters between the two delimiters.*/
FROM NashvilleHousing

 --3.3 Delete column OwnerAddress
 ALTER TABLE NashvilleHousing
 DROP COLUMN OwnerAddress;

 --3.4 Update Column name to OwnerAddress
 sp_RENAME 'NashvilleHousing.OwnerStreet', 'OwnerAddress', 'COLUMN';


--Check the result
EXEC NashvilleH;


--4. Add a new column called "PropertyCity" based on PropertyAddress and keep only street name
ALTER TABLE NashvilleHousing
ADD PropertyCity VARCHAR(30);

UPDATE NashvilleHousing
SET PropertyCity = SUBSTRING(
	PropertyAddress, 
	(CHARINDEX(',', PropertyAddress,1)+1),
	LEN(PropertyAddress));

UPDATE NashvilleHousing
SET PropertyAddress = SUBSTRING(
	PropertyAddress,
	1, 
	(
	CHARINDEX(',', PropertyAddress,1)-1)
	);

EXEC NashvilleH;



--5. Change 1 and 0 to Yes and No in "Sold as Vacant" field 
UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE
WHEN SoldAsVacant = 0 THEN 'No'
WHEN SoldAsVacant = 1 THEN 'Yes'
END;


--Check the result
EXEC NashvilleH;




--6. Identify and remove duplicate rows.

 
  -- 6.1 Duplcate the source table to preserve data source integrity
SELECT * INTO Nashville_DropTable
FROM NashvilleHousing;


  -- 6.2 Drop duplicate lines from new data source based on the following columns: ParcelID, PropertyAddress, SalePrice, OwnerName, SalePrice, LegalReference
DELETE FROM Nashville_DropTable
WHERE LegalReference IN
(SELECT LegalRefA FROM
	(SELECT
		a.LegalReference LegalRefA,
		ROW_NUMBER() OVER (PARTITION BY
					a.ParcelID, 
					b.ParcelID, 
					a.PropertyAddress, 
					b.PropertyAddress, 
					a.OwnerName, 
					b.OwnerName,
					a.SalePrice,
					b.SalePrice,
					a.LegalReference,
					b.LegalReference
					ORDER BY a.ParcelID
									) AS NR
		FROM NashvilleHousing AS a
		JOIN NashvilleHousing AS b
		ON 
		a.ParcelID = b.ParcelID
		AND
		a.LegalReference = b.LegalReference
		AND
		a.UniqueID <> b.UniqueID
		) sub
WHERE sub.NR > 1 )

  -- 6.3 Check

SELECT * FROM
	(SELECT
		a.*,
		ROW_NUMBER() OVER (PARTITION BY
					a.ParcelID, 
					b.ParcelID, 
					a.PropertyAddress, 
					b.PropertyAddress, 
					a.OwnerName, 
					b.OwnerName,
					a.SalePrice,
					b.SalePrice,
					a.LegalReference,
					b.LegalReference
					ORDER BY a.ParcelID
									) AS NR
		FROM Nashville_DropTable a
		JOIN Nashville_DropTable b
		ON 
		a.ParcelID = b.ParcelID
		AND
		a.LegalReference = b.LegalReference
		AND
		a.UniqueID <> b.UniqueID
		) AS sub
		WHERE NR > 1;

-----------------------------------------------------------------------------------------------------------------------------------------