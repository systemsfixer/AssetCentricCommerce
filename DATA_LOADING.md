# Test Data Loading Guide

This guide covers loading test data for the Asset-Centric Commerce Accelerator, including handling of hierarchical relationships and dependencies.

## Overview

The accelerator includes a comprehensive test data loading script that handles hierarchical relationships and ensures proper dependency ordering. The script loads realistic medical equipment data to demonstrate the asset-centric commerce concepts.

## Prerequisites

Before loading test data:

1. **Salesforce CLI** installed and authenticated to your target org
2. **Node.js** (version 12 or higher)
3. **Metadata deployed** - ensure all custom objects and fields are deployed first
4. **Permissions assigned** - the Asset_Taxonomy_Manager permission set should be assigned to your user

## Quick Start

```bash
# Load all test data with proper dependency ordering
node scripts/load-test-data.js
```

## What Gets Loaded

The script loads the following test data in dependency order:

### 1. Asset Categories (25 records)
Medical equipment hierarchy with 4 levels:
- **Level 1**: Medical (root category)
- **Level 2**: Medical Imaging, Laboratory Equipment, Patient Monitoring, Surgical Equipment
- **Level 3**: Diagnostic Imaging, Therapeutic Imaging, Clinical Chemistry, Hematology, etc.
- **Level 4**: X-Ray, CT Scan, MRI, Ultrasound, Nuclear Medicine, etc.

### 2. Products (31 records)
Parts, consumables, and accessories including:
- MRI consumables (helium coolant, RF coils, patient pads)
- CT supplies (contrast syringes, X-ray tubes, detector modules)
- Ultrasound accessories (gel, transducer covers, probes)
- General supplies (ECG electrodes, cleaning wipes, cables)

### 3. Asset Types (31 records)
Specific equipment models from major manufacturers:
- **MRI Systems**: Siemens Magnetom Aera/Skyra, GE Discovery/Optima
- **CT Scanners**: GE Revolution, Siemens SOMATOM Force, Canon Aquilion
- **Ultrasound**: Philips EPIQ Elite, GE LOGIQ E10, Siemens Acuson
- **Lab Analyzers**: Roche cobas, Abbott Architect, Sysmex XN-Series

### 4. Asset Type-Product Relationships (69 records)
Compatibility mappings between equipment and consumables:
- MRI systems → MRI consumables and accessories
- CT scanners → CT contrast supplies and replacement parts
- Ultrasound systems → ultrasound gel, transducers, and covers
- Lab analyzers → reagent kits and quality control materials

## Script Features

### Hierarchical Dependency Resolution
- **Automatic sorting** - Asset_Categories are sorted so parent categories load before children
- **Multi-pass algorithm** - ensures proper dependency order even with complex hierarchies
- **Circular reference detection** - warns about potential issues and handles gracefully

### Data Loading Sequence
1. **Asset_Categories** (hierarchy-sorted)
2. **Products** (independent)
3. **Asset_Types** (depends on Asset_Categories)
4. **Asset_Type_Products** (junction object, depends on both Asset_Types and Products)

### Robust Error Handling
- **Org detection** - automatically finds default org or provides clear guidance
- **Detailed logging** - comprehensive progress reporting with emojis for easy reading
- **Failure reporting** - specific error messages for troubleshooting
- **Graceful degradation** - continues processing other data types if one fails

### Safe Operations
- **External ID upserts** - safe to run multiple times, updates existing records
- **Temporary file management** - creates temp files during processing, cleans up automatically
- **Process interruption handling** - cleans up temp files even if script is interrupted

## Verification

After running the script, verify the data was loaded correctly:

### Command Line Verification
```bash
# Check record counts
sf data query -q "SELECT COUNT() FROM Asset_Category__c"
sf data query -q "SELECT COUNT() FROM Asset_Type__c"
sf data query -q "SELECT COUNT() FROM Product2 WHERE External_Id__c != null"
sf data query -q "SELECT COUNT() FROM Asset_Type_Product__c"
```

**Expected Results:**
- Asset Categories: 25
- Asset Types: 31
- Products: 31
- Asset Type Products: 69

### UI Verification
1. Open your Salesforce org
2. Navigate to **App Launcher** → **Asset Management**
3. Check each tab:
   - **Asset Categories** - Should show hierarchical medical equipment categories
   - **Asset Types** - Should display specific equipment models with manufacturers
   - **Asset Type Products** - Should show compatibility relationships

### Sample Hierarchy Verification
Check that the hierarchy loaded correctly by viewing Asset Categories:
- Medical (CAT-001) - no parent
  - Medical Imaging (CAT-002) - parent: CAT-001
    - Diagnostic Imaging (CAT-003) - parent: CAT-002
      - MRI (CAT-007) - parent: CAT-003

## Troubleshooting

### Common Issues

#### 1. "No default org configured" Error
```bash
# Check available orgs
sf org list

# Set default org
sf config set target-org <your-org-alias>

# Or login to new org
sf org login web -a my-org-alias
sf config set target-org my-org-alias
```

#### 2. Permission Errors
```bash
# Assign required permission set
sf org assign permset -n Asset_Taxonomy_Manager

# Verify assignment
sf org list users
```

#### 3. Metadata Not Deployed
Ensure all custom objects and fields are deployed before loading data:
```bash
# Deploy all metadata
sf project deploy start

# Check deployment status
sf project deploy report
```

#### 4. External ID Field Missing
If you get "No such column 'External_Id__c'" errors:
- Verify External_Id__c fields exist on all objects
- Check field permissions in the Asset_Taxonomy_Manager permission set
- Redeploy metadata if necessary

#### 5. Data Validation Errors
- Check required field validations on custom objects
- Ensure lookup relationships are properly configured
- Verify field lengths are sufficient for test data

### Script Output Examples

#### Successful Run
```
🎯 Starting test data load...

📋 Processing Asset_Categories...
📖 Reading test-data/Asset_Categories.csv...
   Found 25 records
🔄 Sorting records by hierarchy...
   Sorted 25 records by hierarchy
💾 Wrote 25 records to temp-data-load/Asset_Categories.csv
🚀 Upserting Asset_Categories to Asset_Category__c...
   Using default org: test-user@company.com
✅ Asset_Categories: 25 successful, 0 failed

[... similar output for other data types ...]

🎉 All data loaded successfully!
```

#### Error Example
```
❌ No default org configured. Please set a default org first:
   sf config set target-org <your-org-alias>
   Or run: sf org login web
```

## Advanced Usage

### Loading Specific Data Types
The script loads all data types by default, but you can modify the `DATA_CONFIG` array in the script to load only specific types.

### Custom Data
To load your own data:
1. Replace CSV files in the `test-data/` directory
2. Ensure CSV headers match the Salesforce field API names
3. Include External_Id__c values for all records
4. Maintain proper hierarchy in Asset_Categories if using parent-child relationships

### Integration with CI/CD
The script returns appropriate exit codes:
- **Exit 0**: All data loaded successfully
- **Exit 1**: Some or all data loads failed

This makes it suitable for automated deployment pipelines.

## Data Model Reference

### Key Fields

#### Asset_Category__c
- `Name` - Display name of the category
- `External_Id__c` - Unique identifier (CAT-001, CAT-002, etc.)
- `Parent_Category__c` - External ID of parent category (for hierarchy)
- `Description__c` - Detailed description

#### Asset_Type__c
- `Name` - Equipment model name
- `External_Id__c` - Unique identifier (TYPE-001, TYPE-002, etc.)
- `Asset_Category__c` - External ID of associated category
- `Manufacturer__c` - Equipment manufacturer
- `Model_Number__c` - Manufacturer's model number
- `Description__c` - Detailed description

#### Product2
- `Name` - Product name
- `External_Id__c` - Unique identifier (PROD-001, PROD-002, etc.)
- `ProductCode` - Internal product code
- `Description` - Product description
- `Family` - Product family/category
- `IsActive` - Whether product is active

#### Asset_Type_Product__c
- `External_Id__c` - Unique identifier (ATP-001, ATP-002, etc.)
- `Asset_Type__c` - External ID of associated asset type
- `Product__c` - External ID of associated product

This comprehensive test data provides a realistic foundation for demonstrating asset-centric commerce capabilities and can be customized for specific business requirements.
