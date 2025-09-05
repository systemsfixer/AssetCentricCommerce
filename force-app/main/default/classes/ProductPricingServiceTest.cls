/**
 * @description Test class for ProductPricingService
 * @author Asset-Centric Commerce Accelerator
 * @date 2025
 */
@IsTest
public class ProductPricingServiceTest {
    
    /**
     * @description Test data setup
     */
    @TestSetup
    static void setupTestData() {
        // Create test products
        List<Product2> testProducts = new List<Product2>();
        testProducts.add(new Product2(
            Name = 'Test MRI Coil',
            Family = 'Accessories',
            IsActive = true
        ));
        testProducts.add(new Product2(
            Name = 'Test Contrast Agent',
            Family = 'Consumables',
            IsActive = true
        ));
        insert testProducts;
        
        // Create pricebook entries for fallback pricing
        Id standardPricebookId = Test.getStandardPricebookId();
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        
        for (Product2 product : testProducts) {
            pricebookEntries.add(new PricebookEntry(
                Pricebook2Id = standardPricebookId,
                Product2Id = product.Id,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        insert pricebookEntries;
    }
    
    /**
     * @description Test successful pricing with fallback method
     */
    @IsTest
    static void testGetProductPricesWithFallback() {
        // Get test products
        List<Product2> testProducts = [SELECT Id, Name, Family FROM Product2 WHERE Name LIKE 'Test%'];
        
        // Create input for invocable method
        ProductPricingService.FlowInput input = new ProductPricingService.FlowInput();
        input.products = testProducts;
        input.webstoreId = 'test-webstore-id';
        input.effectiveAccountId = 'test-account-id';
        
        List<ProductPricingService.FlowInput> inputs = new List<ProductPricingService.FlowInput>{input};
        
        Test.startTest();
        List<List<ProductPricingService.ProductWithPricing>> results = 
            ProductPricingService.getProductPrices(inputs);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result list');
        List<ProductPricingService.ProductWithPricing> pricedProducts = results[0];
        System.assertEquals(2, pricedProducts.size(), 'Should return two priced products');
        
        // Verify product data
        for (ProductPricingService.ProductWithPricing pricedProduct : pricedProducts) {
            System.assertNotEquals(null, pricedProduct.productId, 'Product ID should not be null');
            System.assertNotEquals(null, pricedProduct.productName, 'Product name should not be null');
            System.assertEquals(1, pricedProduct.quantity, 'Quantity should default to 1');
            System.assertEquals(100.00, pricedProduct.price, 'Price should match pricebook entry');
        }
    }
    
    /**
     * @description Test with empty product list
     */
    @IsTest
    static void testGetProductPricesWithEmptyList() {
        // Create input with empty product list
        ProductPricingService.FlowInput input = new ProductPricingService.FlowInput();
        input.products = new List<Product2>();
        input.webstoreId = 'test-webstore-id';
        input.effectiveAccountId = 'test-account-id';
        
        List<ProductPricingService.FlowInput> inputs = new List<ProductPricingService.FlowInput>{input};
        
        Test.startTest();
        List<List<ProductPricingService.ProductWithPricing>> results = 
            ProductPricingService.getProductPrices(inputs);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result list');
        System.assertEquals(0, results[0].size(), 'Should return empty list for no products');
    }
    
    /**
     * @description Test with null webstore ID
     */
    @IsTest
    static void testGetProductPricesWithNullWebstoreId() {
        // Get test products
        List<Product2> testProducts = [SELECT Id, Name, Family FROM Product2 WHERE Name LIKE 'Test%' LIMIT 1];
        
        // Create input with null webstore ID
        ProductPricingService.FlowInput input = new ProductPricingService.FlowInput();
        input.products = testProducts;
        input.webstoreId = null;
        input.effectiveAccountId = 'test-account-id';
        
        List<ProductPricingService.FlowInput> inputs = new List<ProductPricingService.FlowInput>{input};
        
        Test.startTest();
        List<List<ProductPricingService.ProductWithPricing>> results = 
            ProductPricingService.getProductPrices(inputs);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result list');
        System.assertEquals(0, results[0].size(), 'Should return empty list for invalid input');
    }
    
    /**
     * @description Test products without pricebook entries
     */
    @IsTest
    static void testGetProductPricesWithoutPricebookEntries() {
        // Create product without pricebook entry
        Product2 testProduct = new Product2(
            Name = 'Test Product No Price',
            Family = 'Test Family',
            IsActive = true
        );
        insert testProduct;
        
        // Create input
        ProductPricingService.FlowInput input = new ProductPricingService.FlowInput();
        input.products = new List<Product2>{testProduct};
        input.webstoreId = 'test-webstore-id';
        input.effectiveAccountId = 'test-account-id';
        
        List<ProductPricingService.FlowInput> inputs = new List<ProductPricingService.FlowInput>{input};
        
        Test.startTest();
        List<List<ProductPricingService.ProductWithPricing>> results = 
            ProductPricingService.getProductPrices(inputs);
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size(), 'Should return one result list');
        System.assertEquals(1, results[0].size(), 'Should return one product');
        
        ProductPricingService.ProductWithPricing pricedProduct = results[0][0];
        System.assertEquals(testProduct.Id, pricedProduct.productId, 'Product ID should match');
        System.assertEquals(testProduct.Name, pricedProduct.productName, 'Product name should match');
        System.assertEquals(null, pricedProduct.price, 'Price should be null when no pricebook entry exists');
        System.assertEquals(1, pricedProduct.quantity, 'Quantity should default to 1');
    }
    
    /**
     * @description Test ProductWithPricing constructor
     */
    @IsTest
    static void testProductWithPricingConstructor() {
        Test.startTest();
        ProductPricingService.ProductWithPricing pricedProduct = new ProductPricingService.ProductWithPricing();
        Test.stopTest();
        
        System.assertEquals(1, pricedProduct.quantity, 'Quantity should default to 1');
    }
}
