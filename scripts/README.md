# Test Data Loading Script

This directory contains a Node.js script to load test data into your Salesforce org with proper handling of hierarchical relationships.

## Files

- `load-test-data.js` - Main data loading script

## Prerequisites

1. **Salesforce CLI** must be installed and authenticated to your target org
2. **Node.js** (version 12 or higher)
3. **Default target org** configured, or use `-o` flag with sf commands

## Usage

### Basic Usage
```bash
# From project root directory
node scripts/load-test-data.js
```

### Alternative Usage
```bash
# Make executable and run directly
chmod +x scripts/load-test-data.js
./scripts/load-test-data.js
```

## What the Script Does

1. **Loads data in dependency order:**
   - Asset_Categories (sorted by hierarchy - parents before children)
   - Products (independent)
   - Asset_Types (depends on Asset_Categories)
   - Asset_Type_Products (junction object, depends on both Asset_Types and Products)

2. **Handles hierarchical relationships:**
   - Automatically sorts Asset_Categories so parent categories are loaded before their children
   - Uses external ID fields for all upserts to handle references properly

3. **Provides detailed logging:**
   - Shows progress for each data type
   - Reports success/failure counts
   - Displays specific error messages for failed records

4. **Cleanup:**
   - Creates temporary CSV files during processing
   - Automatically cleans up temp files when complete

## Data Files

The script reads from these CSV files in the `test-data/` directory:
- `Asset_Categories.csv` - Asset category hierarchy
- `Products.csv` - Product catalog
- `Asset_Types.csv` - Asset type definitions
- `Asset_Type_Products.csv` - Junction records linking asset types to products

## Error Handling

- Script will continue processing other data types if one fails
- Detailed error messages are displayed for troubleshooting
- Exit code 0 = success, exit code 1 = failures occurred
- Temporary files are cleaned up even if script is interrupted

## Troubleshooting

1. **Authentication errors:** Ensure you're authenticated to your target org
   ```bash
   sf org list
   sf org login web
   ```

2. **Permission errors:** Ensure your user has create/edit permissions for all objects

3. **Field validation errors:** Check that all required fields are populated in CSV files

4. **External ID conflicts:** The script uses upsert, so existing records with matching External_Id__c will be updated
