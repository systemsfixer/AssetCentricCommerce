# Asset-Centric Commerce Accelerator

## Business Overview

Many medtech and capital equipment companies sell large, complex assets (imaging systems, lab analyzers, therapeutic devices) through direct sales or channel partners. While the initial purchase is high-touch, there is tremendous value in enabling customers to purchase **supplies, consumables, and replacement parts** through a self-service commerce experience. However, B2B commerce does not currently have any out-of-the-box capabilities to directly support surfacing products that are compatible or related to a given asset.

This accelerator provides a reference solution to support **post-purchase commerce** by connecting customer-owned equipment with compatible products and parts.

## Business Problem

Healthcare and industrial equipment companies face several challenges in post-purchase commerce:

- **Complex Equipment Relationships**: Medical devices often have sub-components and accessories that require specific compatible parts
- **Customer Self-Service Gap**: Customers struggle to identify which parts and consumables are compatible with their specific equipment
- **Inventory Optimization**: Companies need to suggest relevant products based on what customers already own
- **Revenue Opportunity**: Post-purchase commerce represents significant recurring revenue that is often underutilized

## Business Goals

### Primary Objectives

1. **Enable Self-Service Commerce**: Allow customers to easily find and purchase parts, consumables, and accessories for their installed equipment
2. **Improve Customer Experience**: Provide intuitive navigation from owned assets to compatible products
3. **Increase Revenue**: Capture more post-purchase revenue through improved product discovery and recommendations
4. **Reduce Support Costs**: Minimize customer service inquiries about part compatibility

### Success Metrics

- Increased self-service commerce adoption rates
- Higher average order values for parts and consumables
- Reduced customer support tickets related to part compatibility
- Improved customer satisfaction scores for post-purchase experience

## Business Requirements

### Core Functionality

#### Asset Management

- **Equipment Hierarchy**: Support complex equipment with sub-components and accessories
- **Asset Classification**: Categorize equipment by type, model, and compatibility groups
- **Ownership Tracking**: Maintain accurate records of customer-owned equipment and components

#### Product Catalog

- **Compatibility Mapping**: Link products to compatible equipment types
- **Smart Filtering**: Show only relevant products based on selected equipment
- **Inventory Intelligence**: Exclude products already owned to avoid duplicate purchases

#### Commerce Experience

- **Intuitive Navigation**: Tree-based view of customer equipment
- **Contextual Recommendations**: Side panel showing compatible products for selected equipment
- **Streamlined Purchasing**: Direct add-to-cart functionality for identified products

### User Experience Requirements

#### Must-Have Features

- **Equipment Tree View**: Hierarchical display of all customer-owned assets and sub-assets
- **Compatible Products Panel**: Dynamic list of parts and consumables compatible with selected equipment
- **Add to Cart Integration**: One-click addition of compatible products to commerce cart

#### Nice-to-Have Features

- **Quantity Selection**: Inline quantity adjustment before adding to cart
- **Expansion Suggestions**: Recommendations for additional sub-assets not yet installed
- **Bulk Ordering**: Multi-select capability for common maintenance items

## Business Use Cases

### Primary Use Case: Maintenance Parts Ordering

**Scenario**: Hospital needs replacement parts for MRI machine
**Process**:

1. Customer logs into commerce portal
2. Navigates to their MRI equipment in asset tree
3. Views compatible parts and consumables in side panel
4. Selects needed items and adds to cart
5. Completes purchase through standard commerce flow

### Secondary Use Case: Consumables Replenishment

**Scenario**: Lab needs to reorder consumables for analyzer
**Process**:

1. Customer selects lab analyzer from equipment tree
2. System shows consumables compatible with that specific model
3. System excludes items already in inventory (if integrated)
4. Customer orders appropriate quantities

### Expansion Use Case: Equipment Upgrades

**Scenario**: Customer wants to add accessories to existing equipment
**Process**:

1. Customer views current equipment configuration
2. System suggests compatible accessories not yet owned
3. Customer evaluates and purchases additional components

## Business Value Proposition

### For Equipment Manufacturers

- **Recurring Revenue Growth**: Systematic approach to post-purchase sales
- **Customer Retention**: Improved service experience increases loyalty
- **Operational Efficiency**: Reduced manual processes for part identification
- **Data Insights**: Better understanding of customer usage patterns

### For Healthcare/Industrial Customers

- **Simplified Procurement**: Easy identification of compatible parts and consumables
- **Reduced Downtime**: Faster access to needed replacement parts
- **Cost Optimization**: Avoid purchasing incompatible or duplicate items
- **Compliance Support**: Ensure parts meet equipment specifications

## Implementation Scope

### Phase 1: Foundation

- Establish equipment hierarchy and categorization
- Create product compatibility framework
- Build basic tree navigation and product filtering

### Phase 2: Commerce Integration ✅ COMPLETE

- ✅ Asset Product Explorer LWC - Interactive component for asset-centric product discovery
- ✅ B2B Commerce pricing integration via ProductPricingService
- ✅ Add-to-cart functionality with quantity selection

### Phase 3: Other Asset-Centric digital experience Use-Cases

- View help articles for asset type
- Submit case for a given asset
- Track warranty status, submit warranty claims

## Success Factors

### Critical Requirements

- **Data Quality**: Accurate equipment and product compatibility data
- **User Adoption**: Intuitive interface that customers actually use
- **Performance**: Fast response times for equipment and product queries
- **Integration**: Seamless connection with existing commerce and ERP systems

### Key Stakeholders

- **Sales Teams**: Need visibility into customer equipment and purchasing patterns
- **Customer Service**: Require tools to assist with part identification
- **Customers**: Must find the system more convenient than current processes
- **IT Teams**: Need maintainable and scalable technical architecture

---

This accelerator establishes the business foundation for asset-centric commerce: connecting customer equipment ownership with relevant product purchasing opportunities to drive post-purchase revenue growth.

## Quick Start & Installation

### Prerequisites

Before setting up this accelerator, ensure you have:

1. **Salesforce CLI** installed and configured

   ```bash
   # Install Salesforce CLI
   npm install -g @salesforce/cli

   # Verify installation
   sf --version
   ```

2. **Node.js** (version 12 or higher)

   ```bash
   node --version
   npm --version
   ```

3. **Git** for cloning the repository

### Commerce Setup Requirements

⚠️ **IMPORTANT**: Before deploying this accelerator, you must enable B2B Commerce in your Salesforce org.

#### Enable B2B Commerce

1. **In Setup, navigate to**: Setup → Digital Experiences → Settings
2. **Enable Digital Experiences**: Turn on "Enable Digital Experiences"
3. **Enable B2B Commerce**: Go to Setup → Commerce → Commerce Settings
4. **Turn on B2B Commerce**: Enable "B2B Commerce" feature

**Why this is required**: The accelerator includes metadata for B2B Commerce objects (`BuyerGroup`, `ProductCatalog`, `ProductCategory`, `ProductCategoryProduct`). These objects are only available when B2B Commerce is enabled in the org. Deployment will fail without this feature enabled.

### Installation Steps

#### 1. Clone and Setup Project

```bash
# Clone the repository
git clone <repository-url>
cd AssetCentricCommerce2

# Install dependencies (if any)
npm install
```

#### 2. Salesforce Org Setup

**Option A: Create New Scratch Org (Recommended for Testing)**

```bash
# Create scratch org
sf org create scratch -f config/project-scratch-def.json -a asset-commerce-scratch

# Set as default org
sf config set target-org asset-commerce-scratch
```

**Option B: Use Existing Org/Sandbox**

```bash
# Login to your org
sf org login web -a my-org-alias

# Set as default org
sf config set target-org my-org-alias
```

#### 3. Deploy Metadata

```bash
# Deploy all metadata to your org
sf project deploy start

# Or deploy specific components
sf project deploy start --source-dir force-app/main/default
```

#### 4. Assign Permissions

```bash
# Assign the Asset Taxonomy Manager permission set (for administrators)
sf org assign permset -n Asset_Taxonomy_Manager

# Assign the ACC Buyer permission set (for buyer users)
sf org assign permset -n ACC_Buyer
```

#### 5. Load Sample Data

The accelerator includes sample data files configured for Salesforce Inspector:

- `sample-data/Asset_Categories.csv` - 61 hierarchical medical equipment categories (including accessory categories)
- `sample-data/Asset_Types.csv` - 52 asset types (main equipment + sub-component models)
- `sample-data/Products.csv` - 81 products (parts, consumables, accessories, sub-component parts)
- `sample-data/Asset_Type_Products.csv` - 152 compatibility relationships
- `sample-data/Accounts.csv` - 12 healthcare organizations (hospitals and medical centers)
- `sample-data/Assets.csv` - 48 medical equipment assets with hierarchical parent-child relationships
- `sample-data/ProductCategories.csv` - 30 product categories for B2B Commerce catalog
- `sample-data/ProductCategoryProducts.csv` - 93 product-to-category relationships
- `sample-data/BuyerAccounts.csv` - 12 buyer account records enabling B2B Commerce for healthcare organizations
- `sample-data/BuyerGroupMembers.csv` - 12 buyer group memberships associating accounts with ACC buyer group

**Data Loading Order:**

Sample data must be loaded in this specific order due to dependencies:

1. **Asset Categories** → **Asset Types** → **Products** → **Asset Type Products**
2. **Accounts** → **Contacts** → **Assets** (parent assets first, then sub-assets)
3. **Product Categories** → **Product Category Products**
4. **Buyer Accounts** → **Buyer Group Members** (after manually updating BuyerGroup with External_Id\_\_c = "ACC")

**Key Loading Tips:**

- Load Asset Categories first, retry failed records 2-3 times until all load successfully
- Load parent Assets before sub-assets (hierarchical relationships)
- CSV headers are configured for Salesforce Inspector lookup format
- **For B2B Commerce**: Manually update your BuyerGroup and ProductCatalog records with External_Id\_\_c = "ACC"
- See [DATA_LOADING.md](DATA_LOADING.md) for complete details

**Sample Asset Hierarchy Examples:**

- MRI systems with RF coils, patient tables, and positioning accessories
- CT scanners with detector arrays, X-ray tube assemblies, and cooling systems
- PET/CT systems with detector rings, attenuation correction, and patient tables
- Ultrasound systems with various transducer probes for different applications

### Verification Steps

After loading data, verify in your org:

```bash
# Quick verification
sf data query -q "SELECT COUNT() FROM Asset_Category__c"
sf data query -q "SELECT COUNT() FROM Asset_Type__c"
```

Then navigate to **App Launcher** → **Asset Management** to explore the loaded data.

### Quick Demo: Asset Product Explorer

After loading sample data, try the interactive Asset Product Explorer:

1. **Navigate to an Account** - Go to any Account record page
2. **Add the Component** - Edit the page and add "Asset Product Explorer" component
3. **Configure Settings** - Set webstoreName for B2B Commerce pricing
4. **Explore Assets** - Select assets in the tree grid to see compatible products
5. **Add to Cart** - Use quantity controls and add-to-cart functionality

The component demonstrates the core asset-centric commerce workflow with real hierarchical asset data and product compatibility relationships.

**💡 Tip**: Use webstore names instead of IDs for environment portability - names stay consistent when deploying between Sandbox and Production.

### Troubleshooting

For common issues like org configuration, permissions, or deployment failures, see the comprehensive troubleshooting guide in [DATA_LOADING.md](DATA_LOADING.md).

### Next Steps

Once installation is complete:

1. **Explore the Data Model** - Review the objects and relationships in Setup
2. **Try the Asset Product Explorer** - Add the LWC component to Account record pages (see [Asset Product Explorer Implementation](ASSET_PRODUCT_EXPLORER_IMPLEMENTATION.md))
3. **Customize for Your Use Case** - Modify fields and relationships as needed
4. **Integrate with Commerce** - Configure B2B Commerce webstore settings for full pricing functionality
5. **Add Business Logic** - Implement custom validation rules and automation

### Development Workflow

For ongoing development:

```bash
# Pull changes from org
sf project retrieve start --source-dir force-app/main/default

# Make changes locally and deploy
sf project deploy start --source-dir force-app/main/default

# Run tests
sf apex run test --test-level RunLocalTests
```

## Key Components

### Data Model

- **Asset_Category\_\_c** - Hierarchical equipment categorization
- **Asset_Type\_\_c** - Specific equipment models with compatibility mapping
- **Asset_Type_Product\_\_c** - Junction for asset-product compatibility
- **ProductPricingService** - Apex class for B2B Commerce pricing integration

### User Interface Components

- **Asset Management App** - Custom Lightning app with asset taxonomy objects
- **Asset Product Explorer LWC** - Interactive component for asset-centric product discovery and cart functionality
- **Product Card LWC** - Individual product display with pricing and quantity selection

### Integration Services

- **AssetProductController** - Apex controller providing asset hierarchy and product compatibility data with tree navigation and webstore integration
- **ProductPricingService** - Commerce ConnectAPI integration for real-time pricing with fallback to standard pricebooks

### Security Model

- **Asset Taxonomy Manager** - Full administrative access to all custom objects and Apex classes
- **ACC Buyer** - Read-only access for buyer users to browse assets and compatible products

## Documentation

- [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Detailed overview of all components and architecture
- [Permission Sets Guide](PERMISSION_SETS.md) - Security model, permission sets, and user access documentation
- [Data Loading Guide](DATA_LOADING.md) - Sample data loading instructions and troubleshooting
- [Asset Product Explorer Implementation](ASSET_PRODUCT_EXPLORER_IMPLEMENTATION.md) - LWC component documentation and usage guide
- [Product Pricing Service](PRODUCT_PRICING_SERVICE.md) - Commerce integration service documentation

This accelerator provides the foundation - customize and extend it to meet your specific business requirements.
