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
# Assign the Asset Taxonomy Manager permission set
sf org assign permset -n Asset_Taxonomy_Manager
```

#### 5. Load Sample Data

The accelerator includes sample data files configured for Salesforce Inspector:

- `sample-data/Asset_Categories.csv` - 52 hierarchical medical equipment categories
- `sample-data/Products.csv` - 38 products (parts, consumables, accessories)
- `sample-data/Asset_Types.csv` - 12 asset types (specific equipment models)  
- `sample-data/Asset_Type_Products.csv` - 38 compatibility relationships

**Key Loading Tips:**
- Load Asset Categories first, retry failed records 2-3 times until all load successfully
- CSV headers are configured for Salesforce Inspector lookup format
- See [DATA_LOADING.md](DATA_LOADING.md) for complete details

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
3. **Configure Settings** - Optionally set webstoreId for B2B Commerce pricing
4. **Explore Assets** - Select assets in the tree grid to see compatible products
5. **Add to Cart** - Use quantity controls and add-to-cart functionality

The component demonstrates the core asset-centric commerce workflow with real hierarchical asset data and product compatibility relationships.

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
- **Asset_Category__c** - Hierarchical equipment categorization
- **Asset_Type__c** - Specific equipment models with compatibility mapping
- **Asset_Type_Product__c** - Junction for asset-product compatibility
- **ProductPricingService** - Apex class for B2B Commerce pricing integration

### User Interface Components
- **Asset Management App** - Custom Lightning app with asset taxonomy objects
- **Asset Product Explorer LWC** - Interactive component for asset-centric product discovery and cart functionality
- **Product Card LWC** - Individual product display with pricing and quantity selection

### Integration Services
- **AssetProductController** - Apex controller providing asset hierarchy and product compatibility data
- **ProductPricingService** - Commerce ConnectAPI integration for real-time pricing

## Documentation

- [Implementation Summary](IMPLEMENTATION_SUMMARY.md) - Detailed overview of all components and architecture
- [Data Loading Guide](DATA_LOADING.md) - Sample data loading instructions and troubleshooting
- [Asset Product Explorer Implementation](ASSET_PRODUCT_EXPLORER_IMPLEMENTATION.md) - LWC component documentation and usage guide
- [Product Pricing Service](PRODUCT_PRICING_SERVICE.md) - Commerce integration service documentation

This accelerator provides the foundation - customize and extend it to meet your specific business requirements.
