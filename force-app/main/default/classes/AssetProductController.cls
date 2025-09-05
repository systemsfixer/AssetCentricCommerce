/**
 * @description Controller for Asset-Product LWC components
 * @author Asset-Centric Commerce Accelerator
 * @date 2025
 */
public with sharing class AssetProductController {
    
    /**
     * @description Wrapper class for asset tree grid data
     */
    public class AssetTreeNode {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String assetNumber;
        @AuraEnabled public String status;
        @AuraEnabled public String assetTypeId;
        @AuraEnabled public String assetTypeName;
        @AuraEnabled public String hierarchyPath;
        @AuraEnabled public String parentId;
        @AuraEnabled public List<AssetTreeNode> children;
        
        public AssetTreeNode() {
            this.children = new List<AssetTreeNode>();
        }
    }
    
    /**
     * @description Wrapper class for compatible products
     */
    public class CompatibleProduct {
        @AuraEnabled public String productId;
        @AuraEnabled public String productName;
        @AuraEnabled public String productFamily;
        @AuraEnabled public String description;
        @AuraEnabled public Decimal price;
        @AuraEnabled public Integer quantity;
        @AuraEnabled public Boolean isActive;
        
        public CompatibleProduct() {
            this.quantity = 1;
            this.isActive = true;
        }
    }
    
    /**
     * @description Get assets for an account in tree structure
     * @param accountId The account ID to get assets for
     * @return List<AssetTreeNode> Hierarchical list of assets
     */
    @AuraEnabled(cacheable=true)
    public static List<AssetTreeNode> getAccountAssets(String accountId) {
        if (String.isBlank(accountId)) {
            return new List<AssetTreeNode>();
        }
        
        try {
            // Query all assets for the account with related asset type information
            List<Asset> assets = [
                SELECT Id, Name, Status, ParentId,
                       Asset_Type__c, Asset_Type__r.Name, Asset_Hierarchy_Path__c
                FROM Asset 
                WHERE AccountId = :accountId 
                ORDER BY Name ASC
            ];
            
            return buildAssetTree(assets);
            
        } catch (Exception e) {
            System.debug('AssetProductController.getAccountAssets error: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving assets: ' + e.getMessage());
        }
    }
    
    /**
     * @description Build hierarchical tree structure from flat asset list
     * @param assets Flat list of Asset records
     * @return List<AssetTreeNode> Tree structure
     */
    private static List<AssetTreeNode> buildAssetTree(List<Asset> assets) {
        Map<Id, AssetTreeNode> nodeMap = new Map<Id, AssetTreeNode>();
        List<AssetTreeNode> rootNodes = new List<AssetTreeNode>();
        
        // First pass: create all nodes
        for (Asset asset : assets) {
            AssetTreeNode node = new AssetTreeNode();
            node.id = asset.Id;
            node.name = asset.Name;
            node.assetNumber = asset.Id; // Use Id as asset number since AssetNumber field may not exist
            node.status = asset.Status;
            node.assetTypeId = asset.Asset_Type__c;
            node.assetTypeName = asset.Asset_Type__r?.Name;
            node.hierarchyPath = asset.Asset_Hierarchy_Path__c;
            node.parentId = asset.ParentId;
            
            nodeMap.put(asset.Id, node);
        }
        
        // Second pass: build tree structure
        for (AssetTreeNode node : nodeMap.values()) {
            if (String.isBlank(node.parentId)) {
                // Root level asset
                rootNodes.add(node);
            } else {
                // Child asset - add to parent's children
                AssetTreeNode parentNode = nodeMap.get(node.parentId);
                if (parentNode != null) {
                    parentNode.children.add(node);
                }
            }
        }
        
        return rootNodes;
    }
    
    /**
     * @description Get compatible products for a specific asset using webstore name
     * @param assetId The asset ID to get compatible products for
     * @param webstoreName The webstore name for pricing context (environment portable)
     * @param effectiveAccountId The account ID for pricing context
     * @return List<CompatibleProduct> List of compatible products with pricing
     */
    @AuraEnabled
    public static List<CompatibleProduct> getCompatibleProductsWithStoreName(String assetId, String webstoreName, String effectiveAccountId) {
        if (String.isBlank(assetId)) {
            return new List<CompatibleProduct>();
        }
        
        try {
            // Get the asset and its asset type
            Asset selectedAsset = [
                SELECT Id, Asset_Type__c 
                FROM Asset 
                WHERE Id = :assetId 
                LIMIT 1
            ];
            
            if (selectedAsset.Asset_Type__c == null) {
                System.debug('AssetProductController: Asset has no Asset Type assigned');
                return new List<CompatibleProduct>();
            }
            
            // Get compatible products through junction object
            List<Asset_Type_Product__c> junctions = [
                SELECT Product__c, Product__r.Id, Product__r.Name, Product__r.Family, 
                       Product__r.Description, Product__r.IsActive
                FROM Asset_Type_Product__c 
                WHERE Asset_Type__c = :selectedAsset.Asset_Type__c
                AND Product__c != null
                AND Product__r.IsActive = true
            ];
            
            if (junctions.isEmpty()) {
                System.debug('AssetProductController: No compatible products found for asset type: ' + selectedAsset.Asset_Type__c);
                return new List<CompatibleProduct>();
            }
            
            // Extract Product2 records for pricing service
            List<Product2> products = new List<Product2>();
            for (Asset_Type_Product__c junction : junctions) {
                Product2 product = new Product2();
                product.Id = junction.Product__r.Id;
                product.Name = junction.Product__r.Name;
                product.Family = junction.Product__r.Family;
                product.Description = junction.Product__r.Description;
                product.IsActive = junction.Product__r.IsActive;
                products.add(product);
            }
            
            // Get pricing information using the existing ProductPricingService
            List<CompatibleProduct> result = new List<CompatibleProduct>();
            
            // Resolve webstore name to ID for pricing service
            String resolvedWebstoreId = null;
            if (String.isNotBlank(webstoreName)) {
                resolvedWebstoreId = getWebstoreId(webstoreName);
                if (String.isBlank(resolvedWebstoreId)) {
                    System.debug('AssetProductController: Could not resolve webstore name: ' + webstoreName);
                }
            }
            
            if (String.isNotBlank(resolvedWebstoreId) && String.isNotBlank(effectiveAccountId)) {
                // Use pricing service to get prices
                ProductPricingService.FlowInput pricingInput = new ProductPricingService.FlowInput();
                pricingInput.products = products;
                pricingInput.webstoreId = resolvedWebstoreId;
                pricingInput.effectiveAccountId = effectiveAccountId;
                
                List<List<ProductPricingService.ProductWithPricing>> pricingResults = 
                    ProductPricingService.getProductPrices(new List<ProductPricingService.FlowInput>{pricingInput});
                
                // Convert pricing results to CompatibleProduct format
                if (!pricingResults.isEmpty() && !pricingResults[0].isEmpty()) {
                    for (ProductPricingService.ProductWithPricing pricedProduct : pricingResults[0]) {
                        CompatibleProduct compatibleProduct = new CompatibleProduct();
                        compatibleProduct.productId = pricedProduct.productId;
                        compatibleProduct.productName = pricedProduct.productName;
                        compatibleProduct.productFamily = pricedProduct.productFamily;
                        compatibleProduct.price = pricedProduct.price;
                        compatibleProduct.quantity = pricedProduct.quantity != null ? pricedProduct.quantity : 1;
                        compatibleProduct.isActive = true;
                        
                        // Add description from original product data
                        for (Product2 originalProduct : products) {
                            if (originalProduct.Id == pricedProduct.productId) {
                                compatibleProduct.description = originalProduct.Description;
                                break;
                            }
                        }
                        
                        result.add(compatibleProduct);
                    }
                }
            } else {
                // No webstore/account context - return products without pricing
                for (Product2 product : products) {
                    CompatibleProduct compatibleProduct = new CompatibleProduct();
                    compatibleProduct.productId = product.Id;
                    compatibleProduct.productName = product.Name;
                    compatibleProduct.productFamily = product.Family;
                    compatibleProduct.description = product.Description;
                    compatibleProduct.isActive = product.IsActive;
                    result.add(compatibleProduct);
                }
            }
            
            System.debug('AssetProductController: Found ' + result.size() + ' compatible products for asset: ' + assetId);
            return result;
            
        } catch (Exception e) {
            System.debug('AssetProductController.getCompatibleProducts error: ' + e.getMessage());
            System.debug('AssetProductController.getCompatibleProducts stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving compatible products: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get asset details by ID
     * @param assetId The asset ID
     * @return AssetTreeNode Asset details
     */
    @AuraEnabled(cacheable=true)
    public static AssetTreeNode getAssetDetails(String assetId) {
        if (String.isBlank(assetId)) {
            return null;
        }
        
        try {
            Asset asset = [
                SELECT Id, Name, Status, ParentId,
                       Asset_Type__c, Asset_Type__r.Name, Asset_Hierarchy_Path__c
                FROM Asset 
                WHERE Id = :assetId 
                LIMIT 1
            ];
            
            AssetTreeNode node = new AssetTreeNode();
            node.id = asset.Id;
            node.name = asset.Name;
            node.assetNumber = asset.Id; // Use Id as asset number since AssetNumber field may not exist
            node.status = asset.Status;
            node.assetTypeId = asset.Asset_Type__c;
            node.assetTypeName = asset.Asset_Type__r?.Name;
            node.hierarchyPath = asset.Asset_Hierarchy_Path__c;
            node.parentId = asset.ParentId;
            
            return node;
            
        } catch (Exception e) {
            System.debug('AssetProductController.getAssetDetails error: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving asset details: ' + e.getMessage());
        }
    }
    
    /**
     * @description Get compatible products for a specific asset (backward compatibility)
     * @param assetId The asset ID to get compatible products for
     * @param webstoreId The webstore ID for pricing context
     * @param effectiveAccountId The account ID for pricing context
     * @return List<CompatibleProduct> List of compatible products with pricing
     */
    @AuraEnabled
    public static List<CompatibleProduct> getCompatibleProducts(String assetId, String webstoreId, String effectiveAccountId) {
        // For backward compatibility, treat webstoreId as webstoreName if it doesn't look like an ID
        String webstoreName = null;
        if (String.isNotBlank(webstoreId) && !webstoreId.startsWith('0ZE')) {
            // Looks like a name, not an ID
            webstoreName = webstoreId;
        }
        return getCompatibleProductsWithStoreName(assetId, webstoreName, effectiveAccountId);
    }
    
    /**
     * @description Resolve webstore name to webstore ID for environment portability
     * @param webstoreName The name of the webstore
     * @return String The webstore ID, or null if not found
     */
    @AuraEnabled(cacheable=true)
    public static String getWebstoreId(String webstoreName) {
        if (String.isBlank(webstoreName)) {
            return null;
        }
        
        try {
            List<WebStore> webstores = [
                SELECT Id, Name 
                FROM WebStore 
                WHERE Name = :webstoreName 
                LIMIT 1
            ];
            
            if (!webstores.isEmpty()) {
                System.debug('AssetProductController: Found webstore ID ' + webstores[0].Id + ' for name: ' + webstoreName);
                return webstores[0].Id;
            } else {
                System.debug('AssetProductController: No webstore found with name: ' + webstoreName);
                return null;
            }
            
        } catch (Exception e) {
            System.debug('AssetProductController.getWebstoreId error: ' + e.getMessage());
            return null;
        }
    }
    
    /**
     * @description Get all available webstore names for configuration
     * @return List<String> List of webstore names
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getAvailableWebstoreNames() {
        try {
            List<WebStore> webstores = [SELECT Name FROM WebStore ORDER BY Name ASC];
            List<String> webstoreNames = new List<String>();
            
            for (WebStore ws : webstores) {
                if (String.isNotBlank(ws.Name)) {
                    webstoreNames.add(ws.Name);
                }
            }
            
            System.debug('AssetProductController: Found ' + webstoreNames.size() + ' webstores');
            return webstoreNames;
            
        } catch (Exception e) {
            System.debug('AssetProductController.getAvailableWebstoreNames error: ' + e.getMessage());
            return new List<String>();
        }
    }
}