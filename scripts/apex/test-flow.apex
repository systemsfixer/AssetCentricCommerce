// Test script to verify the Get Compatible Products for Asset flow
// This script demonstrates how to call the auto-launched flow and test its functionality

// First, let's query for an existing Asset with an Asset Type
List<Asset> testAssets = [SELECT Id, Name, Asset_Type__c FROM Asset WHERE Asset_Type__c != null LIMIT 1];

if (testAssets.isEmpty()) {
    System.debug('No Assets found with Asset Type assigned. Creating test data...');
    
    // Create test Asset Category first (required for Asset Type)
    Asset_Category__c testCategory = new Asset_Category__c(
        Name = 'Test Medical Equipment',
        Description__c = 'Test category for flow validation',
        External_Id__c = 'TEST_CAT_001'
    );
    insert testCategory;
    
    // Create test Asset Type
    Asset_Type__c testAssetType = new Asset_Type__c(
        Name = 'Test MRI Scanner',
        Description__c = 'Test asset type for flow validation',
        Asset_Category__c = testCategory.Id,
        External_Id__c = 'TEST_TYPE_001'
    );
    insert testAssetType;
    
    // Create test Account (required for Asset)
    Account testAccount = new Account(
        Name = 'Test Hospital'
    );
    insert testAccount;
    
    // Create test Asset
    Asset testAsset = new Asset(
        Name = 'Test Hospital MRI Unit',
        Asset_Type__c = testAssetType.Id,
        External_Id__c = 'TEST_ASSET_001',
        AccountId = testAccount.Id
    );
    insert testAsset;
    
    testAssets = new List<Asset>{testAsset};
    System.debug('Created test Asset: ' + testAsset.Name + ' with Asset Type: ' + testAssetType.Name);
}

Asset inputAsset = testAssets[0];
System.debug('Testing flow with Asset: ' + inputAsset.Name + ' (ID: ' + inputAsset.Id + ')');
System.debug('Asset Type ID: ' + inputAsset.Asset_Type__c);

// Call the auto-launched flow
Map<String, Object> flowInputs = new Map<String, Object>();
flowInputs.put('InputAsset', inputAsset);

Flow.Interview flowInterview = Flow.Interview.createInterview('Get_Compatible_Products_for_Asset', flowInputs);
flowInterview.start();

// Get the output
List<Product2> compatibleProducts = (List<Product2>) flowInterview.getVariableValue('CompatibleProducts');

System.debug('Flow execution completed.');
System.debug('Number of compatible products found: ' + (compatibleProducts != null ? compatibleProducts.size() : 0));

if (compatibleProducts != null && !compatibleProducts.isEmpty()) {
    System.debug('Compatible Products:');
    for (Product2 product : compatibleProducts) {
        System.debug('- ' + product.Name + ' (ID: ' + product.Id + ')');
    }
} else {
    System.debug('No compatible products found. This could mean:');
    System.debug('1. No Asset_Type_Product__c records exist for this Asset Type');
    System.debug('2. No Product2 records match the Asset Type Product mappings');
    System.debug('3. The flow terminated early due to null checks');
    
    // Let's check what Asset Type Product mappings exist
    List<Asset_Type_Product__c> mappings = [
        SELECT Id, Asset_Type__c, Product__c, Product__r.Name 
        FROM Asset_Type_Product__c 
        WHERE Asset_Type__c = :inputAsset.Asset_Type__c
    ];
    
    System.debug('Asset Type Product mappings for this Asset Type: ' + mappings.size());
    for (Asset_Type_Product__c mapping : mappings) {
        System.debug('- Mapping to Product: ' + mapping.Product__r.Name);
    }
}

System.debug('Flow test completed successfully!');
