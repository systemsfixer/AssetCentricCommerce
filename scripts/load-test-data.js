#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const DATA_DIR = 'test-data';
const TEMP_DIR = 'temp-data-load';

// Data loading configuration with dependencies
const DATA_CONFIG = [
    {
        name: 'Asset_Categories',
        file: 'Asset_Categories.csv',
        object: 'Asset_Category__c',
        externalIdField: 'External_Id__c',
        needsHierarchySort: true,
        parentField: 'Parent_Category__c'
    },
    {
        name: 'Products',
        file: 'Products.csv',
        object: 'Product2',
        externalIdField: 'External_Id__c',
        needsHierarchySort: false
    },
    {
        name: 'Asset_Types',
        file: 'Asset_Types.csv',
        object: 'Asset_Type__c',
        externalIdField: 'External_Id__c',
        needsHierarchySort: false
    },
    {
        name: 'Asset_Type_Products',
        file: 'Asset_Type_Products.csv',
        object: 'Asset_Type_Product__c',
        externalIdField: 'External_Id__c',
        needsHierarchySort: false
    }
];

/**
 * Parse CSV file and return array of objects
 */
function parseCSV(filePath) {
    console.log(`📖 Reading ${filePath}...`);
    const content = fs.readFileSync(filePath, 'utf8');
    const lines = content.trim().split('\n');
    const headers = lines[0].split(',');
    
    const records = [];
    for (let i = 1; i < lines.length; i++) {
        const values = parseCSVLine(lines[i]);
        const record = {};
        headers.forEach((header, index) => {
            record[header] = values[index] || '';
        });
        records.push(record);
    }
    
    console.log(`   Found ${records.length} records`);
    return records;
}

/**
 * Parse a single CSV line handling quoted values
 */
function parseCSVLine(line) {
    const result = [];
    let current = '';
    let inQuotes = false;
    
    for (let i = 0; i < line.length; i++) {
        const char = line[i];
        
        if (char === '"') {
            inQuotes = !inQuotes;
        } else if (char === ',' && !inQuotes) {
            result.push(current.trim());
            current = '';
        } else {
            current += char;
        }
    }
    
    result.push(current.trim());
    return result;
}

/**
 * Sort Asset Categories by hierarchy (parents before children)
 */
function sortByHierarchy(records, parentField) {
    console.log(`🔄 Sorting records by hierarchy...`);
    
    const sorted = [];
    const remaining = [...records];
    const processed = new Set();
    
    // Add records without parents first
    let added = true;
    while (added && remaining.length > 0) {
        added = false;
        
        for (let i = remaining.length - 1; i >= 0; i--) {
            const record = remaining[i];
            const parentValue = record[parentField];
            
            // If no parent or parent already processed, add this record
            if (!parentValue || processed.has(parentValue)) {
                sorted.push(record);
                processed.add(record.External_Id__c);
                remaining.splice(i, 1);
                added = true;
            }
        }
    }
    
    // If there are still remaining records, there might be circular references
    if (remaining.length > 0) {
        console.warn(`⚠️  Warning: ${remaining.length} records may have circular references, adding them anyway`);
        sorted.push(...remaining);
    }
    
    console.log(`   Sorted ${sorted.length} records by hierarchy`);
    return sorted;
}

/**
 * Write records to temporary CSV file
 */
function writeCSV(records, filePath) {
    if (records.length === 0) {
        console.log(`⚠️  No records to write for ${filePath}`);
        return;
    }
    
    const headers = Object.keys(records[0]);
    const csvContent = [
        headers.join(','),
        ...records.map(record => 
            headers.map(header => {
                const value = record[header] || '';
                // Quote values that contain commas or quotes
                if (value.includes(',') || value.includes('"')) {
                    return `"${value.replace(/"/g, '""')}"`;
                }
                return value;
            }).join(',')
        )
    ].join('\n');
    
    // Ensure temp directory exists
    const tempDir = path.dirname(filePath);
    if (!fs.existsSync(tempDir)) {
        fs.mkdirSync(tempDir, { recursive: true });
    }
    
    fs.writeFileSync(filePath, csvContent);
    console.log(`💾 Wrote ${records.length} records to ${filePath}`);
}

/**
 * Execute Salesforce CLI upsert command
 */
function executeUpsert(config, tempFilePath) {
    console.log(`🚀 Upserting ${config.name} to ${config.object}...`);
    
    try {
        // First check if we have a default org configured
        let targetOrg = '';
        try {
            const orgListResult = execSync('sf org list --json', { encoding: 'utf8' });
            const orgList = JSON.parse(orgListResult);
            const defaultOrg = orgList.result.nonScratchOrgs?.find(org => org.isDefaultUsername) || 
                              orgList.result.scratchOrgs?.find(org => org.isDefaultUsername);
            
            if (defaultOrg) {
                targetOrg = ` -o ${defaultOrg.username}`;
                console.log(`   Using default org: ${defaultOrg.username}`);
            }
        } catch (orgError) {
            console.log(`   No default org found, will prompt for selection`);
        }
        
        const command = `sf data upsert -s ${config.object} -f "${tempFilePath}" -i ${config.externalIdField}${targetOrg} --json`;
        console.log(`   Command: ${command}`);
        
        const result = execSync(command, { 
            encoding: 'utf8',
            stdio: ['pipe', 'pipe', 'pipe']
        });
        
        // Try to parse as JSON, but handle cases where it's not JSON
        let jsonResult;
        try {
            jsonResult = JSON.parse(result);
        } catch (parseError) {
            // If it's not JSON, it might be a prompt or error message
            if (result.includes('Which of these orgs would you like to use?') || result.includes('? Which of')) {
                console.error(`❌ No default org configured. Please set a default org first:`);
                console.error(`   sf config set target-org <your-org-alias>`);
                console.error(`   Or run: sf org login web`);
                return false;
            } else {
                console.error(`❌ Unexpected response from SF CLI:`, result);
                return false;
            }
        }
        
        if (jsonResult.status === 0) {
            const successCount = jsonResult.result.successfulResults?.length || 0;
            const failureCount = jsonResult.result.failedResults?.length || 0;
            
            console.log(`✅ ${config.name}: ${successCount} successful, ${failureCount} failed`);
            
            if (failureCount > 0) {
                console.log(`❌ Failures for ${config.name}:`);
                jsonResult.result.failedResults.forEach(failure => {
                    console.log(`   - ${failure.error}`);
                });
            }
        } else {
            console.error(`❌ Command failed for ${config.name}:`, jsonResult.message);
            return false;
        }
        
    } catch (error) {
        console.error(`❌ Error upserting ${config.name}:`, error.message);
        if (error.message.includes('No default org')) {
            console.error(`   Please set a default org: sf config set target-org <your-org-alias>`);
        }
        return false;
    }
    
    return true;
}

/**
 * Clean up temporary files
 */
function cleanup() {
    if (fs.existsSync(TEMP_DIR)) {
        console.log(`🧹 Cleaning up temporary files...`);
        fs.rmSync(TEMP_DIR, { recursive: true, force: true });
    }
}

/**
 * Main execution function
 */
async function main() {
    console.log('🎯 Starting test data load...\n');
    
    let allSuccessful = true;
    
    try {
        // Process each data type in order
        for (const config of DATA_CONFIG) {
            console.log(`\n📋 Processing ${config.name}...`);
            
            const sourceFile = path.join(DATA_DIR, config.file);
            
            // Check if source file exists
            if (!fs.existsSync(sourceFile)) {
                console.error(`❌ Source file not found: ${sourceFile}`);
                allSuccessful = false;
                continue;
            }
            
            // Parse CSV
            let records = parseCSV(sourceFile);
            
            // Sort by hierarchy if needed
            if (config.needsHierarchySort && config.parentField) {
                records = sortByHierarchy(records, config.parentField);
            }
            
            // Write to temporary file
            const tempFile = path.join(TEMP_DIR, config.file);
            writeCSV(records, tempFile);
            
            // Execute upsert
            const success = executeUpsert(config, tempFile);
            if (!success) {
                allSuccessful = false;
            }
        }
        
    } catch (error) {
        console.error('❌ Unexpected error:', error.message);
        allSuccessful = false;
    } finally {
        cleanup();
    }
    
    // Final status
    console.log('\n' + '='.repeat(50));
    if (allSuccessful) {
        console.log('🎉 All data loaded successfully!');
        process.exit(0);
    } else {
        console.log('💥 Some data loads failed. Check the output above for details.');
        process.exit(1);
    }
}

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n🛑 Process interrupted. Cleaning up...');
    cleanup();
    process.exit(1);
});

process.on('SIGTERM', () => {
    console.log('\n🛑 Process terminated. Cleaning up...');
    cleanup();
    process.exit(1);
});

// Run the script
if (require.main === module) {
    main().catch(error => {
        console.error('💥 Fatal error:', error);
        cleanup();
        process.exit(1);
    });
}
