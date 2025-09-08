# Permission Sets Documentation

This document describes the permission sets available in the Asset-Centric Commerce accelerator and their intended usage scenarios.

## Overview

The accelerator includes two permission sets designed for different user roles in the asset-centric commerce workflow:

1. **Asset Taxonomy Manager** - For administrators and asset managers
2. **ACC Buyer** - For buyer users and customers

## Asset Taxonomy Manager Permission Set

### Purpose

Administrative permission set for users who need to configure and manage the asset taxonomy system, including asset categories, types, and product relationships.

### Target Users

- System Administrators
- Asset Managers
- Product Catalog Managers
- B2B Commerce Administrators

### Permissions Included

#### Object Permissions (Full CRUD)

- **Asset_Category\_\_c** - Create, read, update, delete hierarchical asset categories
- **Asset_Type\_\_c** - Create, read, update, delete specific equipment models
- **Asset_Type_Product\_\_c** - Create, read, update, delete asset-product compatibility relationships
- **Product2** - Create, read, update, delete products (limited modifyAllRecords)
- **ProductCategory** - Create, read, update, delete B2B Commerce product categories
- **ProductCategoryProduct** - Create, read, update, delete category-product relationships

#### Field Permissions

- All custom fields on asset taxonomy objects (editable)
- Formula fields (read-only): Category_Hierarchy_Path**c, Type_Hierarchy_Path**c, Asset_Hierarchy_Path\_\_c
- External ID fields for data loading integration

#### Apex Class Access

- **AssetProductController** - Asset hierarchy and product compatibility services
- **ProductPricingService** - B2B Commerce pricing integration

#### Application Access

- **Asset Management** app visibility

#### Tab Visibility

- Asset Categories, Asset Types, Asset Type Products tabs

### Usage Scenarios

1. **Initial Setup**: Load asset categories and types, configure product relationships
2. **Ongoing Maintenance**: Update asset classifications, add new equipment models
3. **Data Integration**: Manage external ID fields for system integrations
4. **Troubleshooting**: Full access to diagnose and resolve data issues

## ACC Buyer Permission Set

### Purpose

Read-only permission set for buyer users who need to browse their assets and find compatible products for purchase through the commerce experience.

### Target Users

- B2B Commerce Buyers
- Customer Portal Users
- Equipment Operators
- Procurement Users

### Permissions Included

#### Object Permissions (Read-Only)

- **Asset** - Read access to customer-owned assets (record-level security applies)
- **Asset_Category\_\_c** - Read access to asset category hierarchy
- **Asset_Type\_\_c** - Read access to equipment models and specifications
- **Product2** - Read access to product catalog (record-level security applies)

#### Field Permissions (Read-Only)

- **Asset Fields**:
  - `Asset_Type__c` - Equipment type assignment
  - `Asset_Hierarchy_Path__c` - Full hierarchy visualization
- **Asset Category Fields**:
  - `Description__c` - Category descriptions
  - `Parent_Category__c` - Hierarchy relationships
  - `Category_Hierarchy_Path__c` - Path visualization
- **Asset Type Fields**:
  - `Description__c` - Equipment descriptions
  - `Manufacturer__c` - Equipment manufacturer
  - `Model_Number__c` - Equipment model numbers
  - `Type_Hierarchy_Path__c` - Full type hierarchy path
- **Product Fields**:
  - `Asset_Type__c` - Product compatibility information

#### Apex Class Access

- **AssetProductController** - Required for Asset Product Explorer LWC functionality
- **ProductPricingService** - Required for B2B Commerce pricing integration

### Usage Scenarios

1. **Asset Browsing**: View hierarchical list of owned equipment
2. **Product Discovery**: Find products compatible with specific assets
3. **Commerce Integration**: Get pricing and add compatible products to cart
4. **Self-Service**: Independent product selection without administrative support

## Security Considerations

### Principle of Least Privilege

The ACC Buyer permission set follows security best practices:

- Read-only access to minimize data modification risks
- No administrative capabilities
- Field-level security prevents access to sensitive information
- Record-level security (sharing rules) still applies

### Record-Level Security

Both permission sets respect Salesforce sharing model:

- **Asset records**: Buyers typically see only their organization's assets
- **Product records**: Commerce visibility rules and sharing settings apply
- **Custom objects**: Organization-wide defaults and sharing rules control access

### Integration Security

Apex classes use `with sharing` keyword to ensure:

- SOQL queries respect user's record access
- Field-level security is enforced
- User permissions are validated at runtime

## Assignment Instructions

### Command Line Assignment

```bash
# For administrators and asset managers
sf org assign permset -n Asset_Taxonomy_Manager -u your-username

# For buyer users
sf org assign permset -n ACC_Buyer -u buyer-username
```

### Bulk Assignment

For multiple users, consider using:

1. **Setup → Users → Permission Set Assignments**
2. **Data Loader** for bulk permission set assignments
3. **Flow** automation for role-based assignment

## Best Practices

### Permission Set Strategy

1. **Single Responsibility**: Each permission set serves one primary role
2. **Additive Model**: Users may have multiple permission sets for different functions
3. **Environment Consistency**: Permission sets deploy consistently across Sandbox → Production

### User Assignment Guidelines

1. **Asset Taxonomy Manager**: Limit to essential administrative users
2. **ACC Buyer**: Assign to all users who need asset-centric commerce functionality
3. **Regular Review**: Periodically audit permission set assignments

### Customization Considerations

When extending the accelerator:

1. **New Objects**: Add appropriate permissions to relevant permission sets
2. **New Fields**: Include field permissions based on user needs (read vs. edit)
3. **Custom Apex**: Add class access permissions as needed
4. **Integration**: Consider creating additional permission sets for specific integration scenarios

## Troubleshooting

### Common Issues

1. **"Insufficient Privileges"**: User may need ACC Buyer permission set assigned
2. **Empty Asset Lists**: Check record-level sharing and organization-wide defaults
3. **Pricing Not Loading**: Verify ProductPricingService class access and B2B Commerce licensing
4. **Formula Field Errors**: Ensure all referenced fields have appropriate permissions

### Debugging Steps

1. **Permission Set Assignment**: Verify user has correct permission set(s)
2. **Object Permissions**: Check Setup → Permission Sets → Object Settings
3. **Field Permissions**: Review Setup → Permission Sets → Field Permissions
4. **Record Access**: Test with "Login as" to simulate user experience
5. **Debug Logs**: Enable for user to trace permission issues

This permission model enables both administrative management and end-user commerce experiences while maintaining appropriate security boundaries.
