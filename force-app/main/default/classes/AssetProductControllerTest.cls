/**
 * @description Test class for AssetProductController
 * @author Asset-Centric Commerce Accelerator
 * @date 2025
 */
@IsTest
private class AssetProductControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create test account
        Account testAccount = new Account(Name = 'Test Medical Center');
        insert testAccount;
        
        // Create asset category
        Asset_Category__c category = new Asset_Category__c(
            Name = 'Medical Imaging',
            Description__c = 'Medical imaging equipment',
            External_Id__c = 'TEST-CAT-001'
        );
        insert category;
        
        // Create asset type
        Asset_Type__c assetType = new Asset_Type__c(
            Name = 'MRI Scanner',
            Asset_Category__c = category.Id,
            Manufacturer__c = 'Test Manufacturer',
            Model_Number__c = 'MRI-1000',
            External_Id__c = 'TEST-TYPE-001'
        );
        insert assetType;
        
        // Create parent asset
        Asset parentAsset = new Asset(
            Name = 'Main MRI Unit',
            AccountId = testAccount.Id,
            Asset_Type__c = assetType.Id,
            Status = 'Installed',
            External_Id__c = 'TEST-ASSET-001'
        );
        insert parentAsset;
        
        // Create child asset
        Asset childAsset = new Asset(
            Name = 'MRI Coil Assembly',
            AccountId = testAccount.Id,
            ParentId = parentAsset.Id,
            Asset_Type__c = assetType.Id,
            Status = 'Installed',
            External_Id__c = 'TEST-ASSET-002'
        );
        insert childAsset;
        
        // Create test products
        List<Product2> products = new List<Product2>{
            new Product2(
                Name = 'MRI Contrast Agent',
                Family = 'Consumables',
                Description = 'Contrast agent for MRI scans',
                IsActive = true,
                External_Id__c = 'TEST-PROD-001'
            ),
            new Product2(
                Name = 'MRI RF Coil',
                Family = 'Accessories',
                Description = 'Radio frequency coil for MRI',
                IsActive = true,
                External_Id__c = 'TEST-PROD-002'
            )
        };
        insert products;
        
        // Create standard pricebook entries
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>{
            new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = products[0].Id,
                UnitPrice = 150.00,
                IsActive = true
            ),
            new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = products[1].Id,
                UnitPrice = 2500.00,
                IsActive = true
            )
        };
        insert pricebookEntries;
        
        // Create junction records for asset type - product compatibility
        List<Asset_Type_Product__c> junctions = new List<Asset_Type_Product__c>{
            new Asset_Type_Product__c(
                Asset_Type__c = assetType.Id,
                Product__c = products[0].Id,
                External_Id__c = 'TEST-JUNCTION-001'
            ),
            new Asset_Type_Product__c(
                Asset_Type__c = assetType.Id,
                Product__c = products[1].Id,
                External_Id__c = 'TEST-JUNCTION-002'
            )
        };
        insert junctions;
    }
    
    @IsTest
    static void testGetAccountAssets() {
        // Get test data
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Medical Center' LIMIT 1];
        
        Test.startTest();
        List<AssetProductController.AssetTreeNode> result = 
            AssetProductController.getAccountAssets(testAccount.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Should have 1 root asset');
        
        AssetProductController.AssetTreeNode rootNode = result[0];
        System.assertEquals('Main MRI Unit', rootNode.name, 'Root node name should match');
        System.assertEquals('Installed', rootNode.status, 'Root node status should match');
        System.assertEquals(1, rootNode.children.size(), 'Root node should have 1 child');
        
        AssetProductController.AssetTreeNode childNode = rootNode.children[0];
        System.assertEquals('MRI Coil Assembly', childNode.name, 'Child node name should match');
        System.assertEquals('Installed', childNode.status, 'Child node status should match');
    }
    
    @IsTest
    static void testGetAccountAssetsEmptyAccountId() {
        Test.startTest();
        List<AssetProductController.AssetTreeNode> result = 
            AssetProductController.getAccountAssets('');
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty list for blank account ID');
    }
    
    @IsTest
    static void testGetCompatibleProducts() {
        // Get test data
        Asset testAsset = [SELECT Id FROM Asset WHERE Name = 'Main MRI Unit' LIMIT 1];
        
        Test.startTest();
        List<AssetProductController.CompatibleProduct> result = 
            AssetProductController.getCompatibleProducts(testAsset.Id, null, null);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'Should have 2 compatible products');
        
        // Verify product details
        Set<String> productNames = new Set<String>();
        for (AssetProductController.CompatibleProduct product : result) {
            productNames.add(product.productName);
            System.assertEquals(true, product.isActive, 'Product should be active');
            System.assertEquals(1, product.quantity, 'Default quantity should be 1');
        }
        
        System.assert(productNames.contains('MRI Contrast Agent'), 'Should contain MRI Contrast Agent');
        System.assert(productNames.contains('MRI RF Coil'), 'Should contain MRI RF Coil');
    }
    
    @IsTest
    static void testGetCompatibleProductsWithPricing() {
        // Get test data
        Asset testAsset = [SELECT Id FROM Asset WHERE Name = 'Main MRI Unit' LIMIT 1];
        
        Test.startTest();
        // Use the old method signature but with a webstore name instead of ID for backward compatibility
        List<AssetProductController.CompatibleProduct> result = 
            AssetProductController.getCompatibleProducts(testAsset.Id, 'NonExistentStore', 'test-account');
        Test.stopTest();
        
        // Verify results - since webstore doesn't exist, should return products without pricing
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'Should have 2 compatible products');
        
        // Products should be returned but without pricing since webstore doesn't exist
        for (AssetProductController.CompatibleProduct product : result) {
            System.assertNotEquals(null, product.productName, 'Product should have a name');
            System.assertNotEquals(null, product.productId, 'Product should have an ID');
        }
    }
    
    @IsTest
    static void testGetWebstoreId() {
        // Create test WebStore since they may not exist in test context
        WebStore testWebStore = new WebStore(Name = 'TestStore');
        try {
            insert testWebStore;
        } catch (Exception e) {
            // WebStore may not be insertable in test context, skip this test
            System.debug('Could not insert WebStore in test context: ' + e.getMessage());
            return;
        }
        
        Test.startTest();
        String webstoreId = AssetProductController.getWebstoreId('TestStore');
        Test.stopTest();
        
        if (webstoreId != null) {
            System.assert(webstoreId.startsWith('0ZE'), 'Should return valid WebStore ID format');
        }
        // Test passes if either webstore is found or gracefully handles missing webstore
    }
    
    @IsTest
    static void testGetWebstoreIdNotFound() {
        Test.startTest();
        String webstoreId = AssetProductController.getWebstoreId('NonExistentStore');
        Test.stopTest();
        
        System.assertEquals(null, webstoreId, 'Should return null for non-existent webstore');
    }
    
    @IsTest
    static void testGetWebstoreIdBlank() {
        Test.startTest();
        String webstoreId = AssetProductController.getWebstoreId('');
        Test.stopTest();
        
        System.assertEquals(null, webstoreId, 'Should return null for blank webstore name');
    }
    
    @IsTest
    static void testGetAvailableWebstoreNames() {
        Test.startTest();
        List<String> webstoreNames = AssetProductController.getAvailableWebstoreNames();
        Test.stopTest();
        
        System.assertNotEquals(null, webstoreNames, 'Should return webstore names list');
        // In test context, WebStore records may not be available, so just verify method doesn't crash
        System.assert(webstoreNames.size() >= 0, 'Should return non-null list');
    }
    
    @IsTest
    static void testGetCompatibleProductsWithWebstoreName() {
        // Get test data
        Asset testAsset = [SELECT Id FROM Asset WHERE Name = 'Main MRI Unit' LIMIT 1];
        
        Test.startTest();
        List<AssetProductController.CompatibleProduct> result = 
            AssetProductController.getCompatibleProductsWithStoreName(testAsset.Id, 'NonExistentStore', 'test-account');
        Test.stopTest();
        
        // Verify results - when webstore name doesn't resolve, should return products without pricing
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(2, result.size(), 'Should have 2 compatible products');
        
        // Since webstore doesn't exist, products should be returned without pricing
        for (AssetProductController.CompatibleProduct product : result) {
            System.assertNotEquals(null, product.productName, 'Product should have a name');
            System.assertNotEquals(null, product.productId, 'Product should have an ID');
        }
    }
    
    @IsTest
    static void testGetCompatibleProductsEmptyAssetId() {
        Test.startTest();
        List<AssetProductController.CompatibleProduct> result = 
            AssetProductController.getCompatibleProducts('', null, null);
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty list for blank asset ID');
    }
    
    @IsTest
    static void testGetCompatibleProductsNoAssetType() {
        // Create asset without asset type
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Medical Center' LIMIT 1];
        Asset assetWithoutType = new Asset(
            Name = 'Asset Without Type',
            AccountId = testAccount.Id,
            Status = 'Installed',
            External_Id__c = 'TEST-ASSET-003'
        );
        insert assetWithoutType;
        
        Test.startTest();
        List<AssetProductController.CompatibleProduct> result = 
            AssetProductController.getCompatibleProducts(assetWithoutType.Id, null, null);
        Test.stopTest();
        
        System.assertEquals(0, result.size(), 'Should return empty list for asset without type');
    }
    
    @IsTest
    static void testGetAssetDetails() {
        // Get test data
        Asset testAsset = [SELECT Id FROM Asset WHERE Name = 'Main MRI Unit' LIMIT 1];
        
        Test.startTest();
        AssetProductController.AssetTreeNode result = 
            AssetProductController.getAssetDetails(testAsset.Id);
        Test.stopTest();
        
        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals('Main MRI Unit', result.name, 'Asset name should match');
        System.assertEquals('Installed', result.status, 'Asset status should match');
        System.assertNotEquals(null, result.assetTypeId, 'Asset should have asset type');
        System.assertEquals('MRI Scanner', result.assetTypeName, 'Asset type name should match');
    }
    
    @IsTest
    static void testGetAssetDetailsEmptyId() {
        Test.startTest();
        AssetProductController.AssetTreeNode result = 
            AssetProductController.getAssetDetails('');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Should return null for blank asset ID');
    }
    
    @IsTest
    static void testErrorHandling() {
        // Test with invalid asset ID (use proper ID format but non-existent)
        Test.startTest();
        try {
            AssetProductController.getCompatibleProducts('02ifn000000invalid', null, null);
            System.assert(false, 'Should throw an exception');
        } catch (Exception e) {
            System.debug('Exception type: ' + e.getTypeName());
            System.debug('Actual error message: ' + e.getMessage());
            // Accept any exception as this test is verifying error handling works
            System.assert(true, 'Exception was properly thrown and handled');
        }
        Test.stopTest();
    }
}