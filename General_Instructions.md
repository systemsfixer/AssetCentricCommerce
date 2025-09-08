# General Instructions for Asset-Centric Commerce Development

## Deployment Best Practices

### File Creation and Deployment Strategy

- **Create files and deploy immediately** for validation rather than letting multiple files stack up
- This approach helps catch XML validation errors early and prevents cascading issues
- Use Salesforce deployment to validate XML rather than VS Code validation

### Salesforce Object Limitations

- **Product2 Object Constraints**:
  - Does not support Master-Detail relationships pointing up to it
  - Does not support required lookup fields
  - Use optional lookup fields when referencing Product2

## MCP (Model Context Protocol) Guidelines

### Salesforce MCP Server Usage

- **CRITICAL**: Always use the server name `Salesforce DX` when calling MCP tools
- **DO NOT** use the command line `npx -y @salesforce/mcp --orgs DEFAULT_TARGET_ORG --toolsets all` as the server name
- The server name in use_mcp_tool should match the "Connected MCP Servers" list, not the installation command

### Project-Specific Salesforce Org Configuration

- **Default Org**: Use `scocchiarella@aleysian.com.assetcentriccommerce2` (Alias: ACC2)
- **Reasoning**: This is the only org found in the MCP Server's allowlisted orgs
- **Usage**: Use this username for the `usernameOrAlias` parameter in all Salesforce MCP tool calls unless user specifies otherwise

### Salesforce MCP Tool Usage Best Practices

- Always specify the correct directory parameter: `/Users/stevencocchiarella/VSCode/AssetCentricCommerce2`
- Use `sf-get-username` tool when uncertain about which org to target (but default to ACC2 org above)
- For deployment operations, use `sf-deploy-metadata` tool with proper source directories
- For retrieving metadata, use `sf-retrieve-metadata` tool

### MCP Connection Troubleshooting

- **Server Connection Error**: If you encounter "No connection found for server" error:
  - Verify you're using `Salesforce DX` as the server name, not the installation command
  - Check the "Connected MCP Servers" section in environment details for exact server names
  - The MCP server name in the environment may not match the actual connected server
  - Try using standard Salesforce CLI commands as fallback: `sf org assign permset -n PermissionSetName`
  - Ensure target org is configured: `sf config set target-org your-org-alias`

### MCP Issue Troubleshooting

- **Master-Detail Field Configuration**: Do not specify `<required>true</required>` for Master-Detail fields as they are automatically required. This will cause deployment errors.
- **Permission Set Field Permissions**: Do not include field-level permissions for Master-Detail fields in permission sets. Master-Detail fields inherit permissions from object-level permissions automatically.
- **External ID Field Permissions**: Do not include field-level permissions for required External ID fields in permission sets. Required fields inherit permissions from object-level permissions automatically.

## Development Workflow

1. Create metadata files
2. Deploy immediately using MCP Salesforce tools
3. Validate deployment success before proceeding
4. Document any issues encountered
5. Update this file with lessons learned

## Formula Field Implementation

### Hierarchy Path Formula Fields

The project includes user-friendly hierarchy path formula fields that provide visual representation of asset relationships:

#### Asset Category Hierarchy Path (`Category_Hierarchy_Path__c`)

- **Object**: Asset_Category\_\_c
- **Purpose**: Shows up to 5 levels of category hierarchy using ➤ arrow symbol
- **Formula Pattern**: Uses BLANKVALUE for clean syntax
- **Example Output**: "MRI Systems ➤ Medical Imaging ➤ Medical Equipment ➤ Healthcare"

#### Asset Type Hierarchy Path (`Type_Hierarchy_Path__c`)

- **Object**: Asset_Type\_\_c
- **Purpose**: Shows Asset Type name plus complete category hierarchy
- **Dependencies**: References Category_Hierarchy_Path\_\_c field
- **Example Output**: "Magnetom Aera 1.5T ➤ MRI Systems ➤ Medical Imaging ➤ Medical Equipment"

#### Asset Hierarchy Path (`Asset_Hierarchy_Path__c`)

- **Object**: Asset (standard object)
- **Purpose**: Shows Asset name plus complete type and category hierarchy
- **Dependencies**: References Type_Hierarchy_Path\_\_c field
- **Example Output**: "Main Campus MRI Unit ➤ Magnetom Aera 1.5T ➤ MRI Systems ➤ Medical Imaging"

### Formula Field Best Practices

- **Use BLANKVALUE**: Cleaner syntax than nested IF statements for null checking
- **Visual Separators**: Use ➤ emoji arrow for clear hierarchy visualization
- **List View Friendly**: Design formulas for optimal display in list views and reports
- **Permission Set Access**: Include formula fields in permission sets with editable=false, readable=true

## Project-Specific Notes

- Focus on medtech/capital equipment use cases
- Asset hierarchy: Category > Type > Individual Assets
- Support post-purchase commerce scenarios
- Maintain compatibility mapping between assets and products
