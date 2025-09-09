/**
 * @description Product data structure with pricing information for Flow integration
 * @author Asset-Centric Commerce Accelerator
 * @date 2025
 * @note This class provides Flow integration as an Apex Defined Resource
 */
global class ProductWithPricing {
  @AuraEnabled
  @InvocableVariable(label='Product ID' description='Salesforce Product2 ID')
  global String productId;

  @AuraEnabled
  @InvocableVariable(label='Product Name' description='Name of the product')
  global String productName;

  @AuraEnabled
  @InvocableVariable(
    label='Product Family'
    description='Product family classification'
  )
  global String productFamily;

  @AuraEnabled
  @InvocableVariable(label='Price' description='Unit price of the product')
  global Decimal price;

  @AuraEnabled
  @InvocableVariable(
    label='Quantity'
    description='Quantity (default 1 for compatibility)'
  )
  global Integer quantity;

  /**
   * @description Default constructor
   */
  global ProductWithPricing() {
    this.quantity = 1;
  }

  /**
   * @description Constructor with all parameters
   * @param productId Salesforce Product2 ID
   * @param productName Name of the product
   * @param productFamily Product family classification
   * @param price Unit price of the product
   * @param quantity Quantity (defaults to 1 if null)
   */
  global ProductWithPricing(
    String productId,
    String productName,
    String productFamily,
    Decimal price,
    Integer quantity
  ) {
    this.productId = productId;
    this.productName = productName;
    this.productFamily = productFamily;
    this.price = price;
    this.quantity = quantity != null ? quantity : 1;
  }
}
