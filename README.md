
# Overview

In this project I cleaned the data from a table called `NashvilleHousing` with SQL using Data Manipulation Language and Data Definition Language and string functions.

# Data set:

Data set was orignally a CSV table which was imported in SQL Server with Python, containing information regarding real estate transactions in Nashiville Metropolitan Area, United States. 
This data set had the following issues (written in the order of script execution):
   * SalesDate with data type datetime needed to be changed to date as all time stamps were 00:00
   * "PropertyAddress" column had null values
   * "PropertyAddress" contained address, city, state in the same cell
   * "Sold as Vacant" column had inconsistent data (some 1 and 0 while other lines were "Yes" and "No")
   *  Contained duplicated lines 

# Transformations


1. **Update Sale Date Format**: 
   - Converted the `SaleDate` column format from `datetime` to `date` using CONVERT function as timestamp was always 00:00.

2. **Populate null cells in "PropertyAddress"**:
   - Filled null values in the PropertyAddress column based on non-null values with the same ParcelID using SELF JOIN.

3. **Break out "OwnerAddress" into individual columns**:
   - Added new columns `OwnerStreet`, `OwnerCity`, and `OwnerState`.
   - Split the `OwnerAddress` column into `OwnerStreet`, `OwnerCity`, and `OwnerState`.
   - Deleted the `OwnerAddress` column.
   - Renamed the `OwnerStreet` column to `OwnerAddress`.

4. **Add  "PropertyCity" column**:
   - Added a new column `PropertyCity` based on `PropertyAddress`, keeping only the city name.

5. **Change 1 and 0 to "Yes" and "No"**:
   - Updated the `SoldAsVacant` field values from 1 and 0 to 'Yes' and 'No'. 

6. **Remove Duplicates**:
   - Identified and removed duplicate rows if the following combination of values from these columns was found more than once using ROW_NUMBER() window function: <br>
      ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference).

# Usage

To execute this projects, import the file using the attached excel file and python script.

# Credits

I was looking for dataset and ideas when I discovered this project intiative and data source has been from 'AlexTheAnalyst', to whom I say thank you. I used his dataset and ideas, to see if I can do them myself in my own way and also added other things to the script. 

 