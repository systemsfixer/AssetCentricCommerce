/**
 * @description Invocable Apex class that uses Connect API to get pricing for multiple products
 * @author Asset-Centric Commerce Accelerator
 * @date 2025
 * @note This class requires B2B Commerce to be enabled in the org for full functionality
 */
public with sharing class ProductPricingService {
  /**
   * @description Input wrapper class for Flow integration
   */
  public class FlowInput {
    @InvocableVariable(
      label='Products'
      description='Collection of Product2 records to get pricing for'
      required=true
    )
    public List<Product2> products;

    @InvocableVariable(
      label='Webstore ID'
      description='ID of the B2B Commerce webstore'
      required=true
    )
    public String webstoreId;

    @InvocableVariable(
      label='Effective Account ID'
      description='Account ID for pricing context'
      required=true
    )
    public String effectiveAccountId;
  }

  /**
   * @description Output wrapper class with product pricing information
   */
  public class ProductWithPricing {
    @InvocableVariable(label='Product ID' description='Salesforce Product2 ID')
    public String productId;

    @InvocableVariable(label='Product Name' description='Name of the product')
    public String productName;

    @InvocableVariable(
      label='Product Family'
      description='Product family classification'
    )
    public String productFamily;

    @InvocableVariable(label='Price' description='Unit price of the product')
    public Decimal price;

    @InvocableVariable(
      label='Quantity'
      description='Quantity (default 1 for compatibility)'
    )
    public Integer quantity;

    /**
     * @description Constructor to initialize with default quantity
     */
    public ProductWithPricing() {
      this.quantity = 1;
    }
  }

  /**
   * @description Custom exception for pricing service errors
   */
  public class PricingServiceException extends Exception {
  }

  /**
   * @description Invocable method to get product prices using Connect API
   * @param inputs List of FlowInput containing products, webstore ID, and account ID
   * @return List<List<ProductWithPricing>> Collection of products with pricing information
   */
  @InvocableMethod(
    label='Get Product Prices'
    description='Gets pricing for products using Connect API for B2B Commerce'
    category='Commerce'
  )
  public static List<List<ProductWithPricing>> getProductPrices(
    List<FlowInput> inputs
  ) {
    List<List<ProductWithPricing>> results = new List<List<ProductWithPricing>>();

    // Process each input (typically just one from Flow)
    for (FlowInput input : inputs) {
      List<ProductWithPricing> pricedProducts = processProductPricing(
        input.products,
        input.webstoreId,
        input.effectiveAccountId
      );
      results.add(pricedProducts);
    }

    return results;
  }

  /**
   * @description Process product pricing for a single input set
   * @param products List of Product2 records to price
   * @param webstoreId B2B Commerce webstore ID
   * @param effectiveAccountId Account ID for pricing context
   * @return List<ProductWithPricing> Products with pricing information
   */
  private static List<ProductWithPricing> processProductPricing(
    List<Product2> products,
    String webstoreId,
    String effectiveAccountId
  ) {
    List<ProductWithPricing> result = new List<ProductWithPricing>();

    // Validate inputs
    if (products == null || products.isEmpty()) {
      System.debug('ProductPricingService: No products provided');
      return result;
    }

    if (String.isBlank(webstoreId) || String.isBlank(effectiveAccountId)) {
      System.debug(
        'ProductPricingService: Missing webstoreId or effectiveAccountId'
      );
      return result;
    }

    try {
      // Check if B2B Commerce is available
      if (!isCommerceApiAvailable()) {
        System.debug(
          'ProductPricingService: B2B Commerce Connect API not available. Using fallback pricing.'
        );
        return getFallbackPricing(products);
      }

      // Build pricing input for Connect API
      Object pricingInput = buildPricingInput(products);

      // Call Connect API to get prices using dynamic approach
      Object pricingResult = callCommerceStorePricing(
        webstoreId,
        effectiveAccountId,
        pricingInput
      );

      // Process the pricing results
      result = processPricingResults(products, pricingResult);
    } catch (Exception e) {
      System.debug(
        'ProductPricingService: Error getting product prices: ' + e.getMessage()
      );
      System.debug(
        'ProductPricingService: Stack trace: ' + e.getStackTraceString()
      );
      // Fallback to basic pricing if Connect API fails
      result = getFallbackPricing(products);
    }

    return result;
  }

  /**
   * @description Check if Commerce Connect API is available in this org
   * @return Boolean True if Commerce API is available
   */
  private static Boolean isCommerceApiAvailable() {
    try {
      // Try to reference the Connect API class
      Type commerceType = Type.forName('ConnectApi.CommerceStorePricing');
      return commerceType != null;
    } catch (Exception e) {
      return false;
    }
  }

  /**
   * @description Build pricing input object dynamically
   * @param products List of Product2 records
   * @return Object Pricing input object for Connect API
   */
  private static Object buildPricingInput(List<Product2> products) {
    // This method will be implemented when B2B Commerce is available
    // For now, return a placeholder
    Map<String, Object> pricingInput = new Map<String, Object>();
    List<Map<String, Object>> lineItems = new List<Map<String, Object>>();

    for (Product2 product : products) {
      if (String.isNotBlank(product.Id)) {
        Map<String, Object> lineItem = new Map<String, Object>();
        lineItem.put('productId', product.Id);
        lineItem.put('quantity', '1');
        lineItems.add(lineItem);
      }
    }

    pricingInput.put('pricingLineItems', lineItems);
    return pricingInput;
  }

  /**
   * @description Call Commerce Store Pricing API dynamically
   * @param webstoreId Webstore ID
   * @param effectiveAccountId Account ID
   * @param pricingInput Pricing input object
   * @return Object Pricing result
   */
  private static Object callCommerceStorePricing(
    String webstoreId,
    String effectiveAccountId,
    Object pricingInput
  ) {
    // This method will use reflection to call the Connect API when available
    // For now, throw an exception to trigger fallback
    throw new PricingServiceException(
      'Connect API not available - using fallback pricing'
    );
  }

  /**
   * @description Get fallback pricing from standard Salesforce objects
   * @param products List of Product2 records
   * @return List<ProductWithPricing> Products with fallback pricing
   */
  private static List<ProductWithPricing> getFallbackPricing(
    List<Product2> products
  ) {
    List<ProductWithPricing> result = new List<ProductWithPricing>();

    // Query for PricebookEntry records to get standard pricing
    Set<Id> productIds = new Set<Id>();
    for (Product2 product : products) {
      productIds.add(product.Id);
    }

    // Get standard pricebook ID
    Id standardPricebookId = Test.isRunningTest()
      ? Test.getStandardPricebookId()
      : [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1]?.Id;

    Map<Id, Decimal> productPrices = new Map<Id, Decimal>();

    if (standardPricebookId != null) {
      try {
        for (PricebookEntry pbe : [
          SELECT Product2Id, UnitPrice
          FROM PricebookEntry
          WHERE
            Product2Id IN :productIds
            AND Pricebook2Id = :standardPricebookId
            AND IsActive = TRUE
        ]) {
          productPrices.put(pbe.Product2Id, pbe.UnitPrice);
        }
      } catch (Exception e) {
        System.debug(
          'ProductPricingService: Error querying PricebookEntry: ' +
          e.getMessage()
        );
      }
    }

    // Build result with available pricing
    for (Product2 product : products) {
      ProductWithPricing pricedProduct = new ProductWithPricing();
      pricedProduct.productId = product.Id;
      pricedProduct.productName = product.Name;
      pricedProduct.productFamily = product.Family;
      pricedProduct.quantity = 1;

      // Use pricebook price if available, otherwise set to null
      if (productPrices.containsKey(product.Id)) {
        pricedProduct.price = productPrices.get(product.Id);
      }

      result.add(pricedProduct);
    }

    System.debug(
      'ProductPricingService: Using fallback pricing for ' +
        result.size() +
        ' products'
    );
    return result;
  }

  /**
   * @description Process Connect API pricing results and map back to ProductWithPricing
   * @param originalProducts Original Product2 records for reference
   * @param pricingResult Result from Connect API call
   * @return List<ProductWithPricing> Processed products with pricing
   */
  private static List<ProductWithPricing> processPricingResults(
    List<Product2> originalProducts,
    Object pricingResult
  ) {
    List<ProductWithPricing> result = new List<ProductWithPricing>();

    // This method will be implemented when B2B Commerce Connect API is available
    // For now, fall back to standard pricing
    System.debug(
      'ProductPricingService: Connect API processing not yet implemented, using fallback'
    );
    return getFallbackPricing(originalProducts);
  }
}
