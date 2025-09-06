# Sample Data Loading

This project includes sample data files configured for easy loading with Salesforce Inspector.

## Sample Data Files

- `sample-data/Asset_Categories.csv` - 52 hierarchical medical equipment categories
- `sample-data/Products.csv` - 38 products (parts, consumables, accessories)
- `sample-data/Asset_Types.csv` - 12 asset types (specific equipment models)  
- `sample-data/Asset_Type_Products.csv` - 38 compatibility relationships
- `sample-data/ProductCategories.csv` - 24 product categories for B2B Commerce catalog
- `sample-data/ProductCategoryProducts.csv` - 65 product-to-category relationships

## Loading with Salesforce Inspector

The CSV files are configured with column headers that match Salesforce Inspector's expected format for lookup relationships (e.g., `Parent_Category__r:Asset_Category__c:External_Id__c`).

### Load Order & Key Tips

1. **Asset Categories first** - Load `Asset_Categories.csv` to `Asset_Category__c` object
   - **Important**: Some records will fail initially due to parent-child dependencies
   - **Retry failed records 2-3 times** until all 52 categories load successfully
   
2. **Products** - Load `Products.csv` to `Product2` object

3. **Asset Types** - Load `Asset_Types.csv` to `Asset_Type__c` object

4. **Asset Type Products** - Load `Asset_Type_Products.csv` to `Asset_Type_Product__c` object

5. **Product Categories** - Load `ProductCategories.csv` to `ProductCategory` object
   - **Note**: Uses standard B2B Commerce object, requires valid CatalogId
   
6. **Product Category Products** - Load `ProductCategoryProducts.csv` to `ProductCategoryProduct` object
   - **Note**: Links products to categories with primary/secondary relationships

### Expected Record Counts
- Asset Categories: 52
- Products: 38  
- Asset Types: 12
- Asset Type Products: 38
- Product Categories: 24
- Product Category Products: 65

The hierarchical retry process for Asset Categories is the key to successful loading - parent categories must exist before child categories can be created.
