# Sample Data Loading

This project includes sample data files configured for easy loading with Salesforce Inspector.

## Sample Data Files

- `sample-data/Asset_Categories.csv` - 61 hierarchical medical equipment categories (including accessory categories)
- `sample-data/Asset_Types.csv` - 52 asset types (main equipment + sub-component models)
- `sample-data/Products.csv` - 38 products (parts, consumables, accessories)
- `sample-data/Asset_Type_Products.csv` - 38 compatibility relationships
- `sample-data/Accounts.csv` - 12 healthcare organizations (hospitals and medical centers)
- `sample-data/Contacts.csv` - 36 healthcare contacts across all hospitals
- `sample-data/Assets.csv` - 48 medical equipment assets with hierarchical parent-child relationships
- `sample-data/ProductCategories.csv` - 24 product categories for B2B Commerce catalog
- `sample-data/ProductCategoryProducts.csv` - 65 product-to-category relationships

## Loading with Salesforce Inspector

The CSV files are configured with column headers that match Salesforce Inspector's expected format for lookup relationships (e.g., `Parent_Category__r:Asset_Category__c:External_Id__c`).

### Load Order & Key Tips

1. **Asset Categories first** - Load `Asset_Categories.csv` to `Asset_Category__c` object
   - **Important**: Some records will fail initially due to parent-child dependencies
   - **Retry failed records 2-3 times** until all 52 categories load successfully

2. **Asset Types** - Load `Asset_Types.csv` to `Asset_Type__c` object
   - Links to Asset Categories via External_Id\_\_c relationships

3. **Products** - Load `Products.csv` to `Product2` object

4. **Asset Type Products** - Load `Asset_Type_Products.csv` to `Asset_Type_Product__c` object
   - Links Asset Types to compatible Products

5. **Accounts** - Load `Accounts.csv` to `Account` object
   - 12 healthcare organizations with External_Id\_\_c for data loading

6. **Contacts** - Load `Contacts.csv` to `Contact` object
   - Links to Accounts via External_Id\_\_c relationships
   - 36 healthcare contacts (3 per hospital: CMO, IT Director, Procurement Manager)
   - All emails use .invalid domain, all phones use 555- prefix for safety

7. **Assets** - Load `Assets.csv` to `Asset` object
   - **Important**: Load parent assets first, then sub-assets (ParentId relationships)
   - Links to Accounts and Asset Types via External_Id\_\_c relationships
   - 48 medical equipment assets with hierarchical structure (25 parent + 23 sub-assets)
   - Examples: MRI systems with coils, tables; CT scanners with detectors, cooling systems

8. **Product Categories** - Load `ProductCategories.csv` to `ProductCategory` object
   - **Note**: Uses standard B2B Commerce object, requires valid CatalogId
9. **Product Category Products** - Load `ProductCategoryProducts.csv` to `ProductCategoryProduct` object
   - **Note**: Links products to categories with primary/secondary relationships

### Expected Record Counts

- Asset Categories: 61 (56 main categories + 5 accessory categories)
- Asset Types: 52 (31 main equipment + 21 sub-component types)
- Products: 38
- Asset Type Products: 38
- Accounts: 12
- Contacts: 36
- Assets: 48 (25 parent assets + 23 sub-assets)
- Product Categories: 24
- Product Category Products: 65

The hierarchical retry process for Asset Categories is the key to successful loading - parent categories must exist before child categories can be created.
