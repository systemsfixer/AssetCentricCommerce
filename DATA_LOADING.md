# Sample Data Loading

This project includes sample data files configured for easy loading with Salesforce Inspector.

## Sample Data Files

- `sample-data/Asset_Categories.csv` - 61 hierarchical medical equipment categories (including accessory categories)
- `sample-data/Asset_Types.csv` - 52 asset types (main equipment + sub-component models)
- `sample-data/Products.csv` - 81 products (parts, consumables, accessories, sub-component parts)
- `sample-data/Asset_Type_Products.csv` - 152 compatibility relationships
- `sample-data/Accounts.csv` - 12 healthcare organizations (hospitals and medical centers)
- `sample-data/Contacts.csv` - 36 healthcare contacts across all hospitals
- `sample-data/Assets.csv` - 48 medical equipment assets with hierarchical parent-child relationships
- `sample-data/ProductCategories.csv` - 30 product categories for B2B Commerce catalog
- `sample-data/ProductCategoryProducts.csv` - 93 product-to-category relationships
- `sample-data/BuyerAccounts.csv` - 12 buyer account records enabling B2B Commerce for healthcare organizations
- `sample-data/BuyerGroupMembers.csv` - 12 buyer group memberships associating accounts with ACC buyer group

## Loading with Salesforce Inspector

The CSV files are configured with column headers that match Salesforce Inspector's expected format for lookup relationships (e.g., `Parent_Category__r:Asset_Category__c:External_Id__c`).

### Critical Loading Order

⚠️ **IMPORTANT**: Data must be loaded in this exact order due to lookup relationships and dependencies:

#### Phase 1: Core Asset Data

1. **Asset Categories** → 2. **Asset Types** → 3. **Products** → 4. **Asset Type Products**

#### Phase 2: Account & Asset Data

5. **Accounts** → 6. **Contacts** → 7. **Assets** (parents first, then sub-assets)

#### Phase 3: Commerce Catalog Data

8. **Product Categories** → 9. **Product Category Products**

#### Phase 4: B2B Commerce Setup (Optional)

10. **Manually update BuyerGroup** (External_Id\_\_c = "ACC") → 11. **Manually update ProductCatalog** (External_Id\_\_c = "ACC") → 12. **Buyer Accounts** → 13. **Buyer Group Members**

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

### B2B Commerce Configuration (Optional)

If you need to configure B2B Commerce buyer groups and catalogs:

10. **Update BuyerGroup External ID** - Manually update your existing BuyerGroup record
    - **Action**: Edit the BuyerGroup record created with your B2B Commerce store
    - **Set External_Id\_\_c = "ACC"**
    - Use this for environment-portable buyer group references in BuyerGroupMembers.csv

11. **Update ProductCatalog External ID** - Manually update your existing ProductCatalog record
    - **Action**: Edit the ProductCatalog record created with your B2B Commerce store
    - **Set External_Id\_\_c = "ACC"**
    - Use this for environment-portable catalog references

12. **Buyer Accounts** - Load `BuyerAccounts.csv` to `BuyerAccount` object
    - **Note**: Enables all 12 healthcare accounts as active buyers in B2B Commerce
    - Links to Accounts via External_Id\_\_c relationships
    - **Must be loaded before** BuyerGroupMembers

13. **BuyerGroup Members** - Load `BuyerGroupMembers.csv` to `BuyerGroupMember` object
    - **Note**: Associates all 12 healthcare accounts with the "ACC" buyer group
    - Uses External ID lookups for both BuyerGroup and Account relationships
    - **Load after** BuyerAccounts and updating BuyerGroup External IDs manually

### Expected Record Counts

- Asset Categories: 61 (56 main categories + 5 accessory categories)
- Asset Types: 52 (31 main equipment + 21 sub-component types)
- Products: 81 (57 original + 24 sub-component parts)
- Asset Type Products: 152 (121 original + 31 new sub-component relationships)
- Accounts: 12
- Contacts: 36
- Assets: 48 (25 parent assets + 23 sub-assets)
- Product Categories: 30 (25 original + 5 component part categories)
- Product Category Products: 93 (69 original + 24 new sub-component relationships)
- Buyer Accounts: 12 (enabling B2B Commerce for healthcare organizations)
- Buyer Group Members: 12 (associating accounts with ACC buyer group)

The hierarchical retry process for Asset Categories is the key to successful loading - parent categories must exist before child categories can be created.
