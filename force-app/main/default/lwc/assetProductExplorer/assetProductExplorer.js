import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAccountAssets from '@salesforce/apex/AssetProductController.getAccountAssets';
import getCompatibleProductsWithStoreName from '@salesforce/apex/AssetProductController.getCompatibleProductsWithStoreName';

const TREE_COLUMNS = [
    {
        label: 'Asset Name',
        fieldName: 'name',
        type: 'text',
        cellAttributes: {
            iconName: { fieldName: 'iconName' }
        }
    },
    {
        label: 'Asset Number',
        fieldName: 'assetNumber',
        type: 'text'
    },
    {
        label: 'Status',
        fieldName: 'status',
        type: 'text'
    },
    {
        label: 'Asset Type',
        fieldName: 'assetTypeName',
        type: 'text'
    },
    {
        label: 'Hierarchy Path',
        fieldName: 'hierarchyPath',
        type: 'text'
    }
];

export default class AssetProductExplorer extends LightningElement {
    @api recordId; // Account ID when used on Account page
    @api webstoreName; // B2B Commerce webstore name (environment portable)
    @api effectiveAccountId; // Account ID for pricing context
    
    @track assetData = [];
    @track selectedAssetId;
    @track selectedAssetName;
    @track compatibleProducts = [];
    @track isLoading = false;
    @track isLoadingProducts = false;
    @track error;
    
    treeColumns = TREE_COLUMNS;
    
    connectedCallback() {
        if (this.recordId) {
            this.loadAssets();
        }
    }
    
    @wire(getAccountAssets, { accountId: '$recordId' })
    wiredAssets({ error, data }) {
        if (data) {
            this.assetData = this.processAssetData(data);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.assetData = [];
            this.showToast('Error', 'Error loading assets: ' + error.body.message, 'error');
        }
    }
    
    processAssetData(data) {
        if (!data || !Array.isArray(data)) {
            return [];
        }
        
        return data.map(asset => ({
            ...asset,
            iconName: this.getAssetIcon(asset.status),
            expanded: false
        }));
    }
    
    getAssetIcon(status) {
        switch (status) {
            case 'Installed':
                return 'utility:success';
            case 'Shipped':
                return 'utility:truck';
            case 'Purchased':
                return 'utility:shopping_cart';
            default:
                return 'utility:asset_object';
        }
    }
    
    handleAssetSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows && selectedRows.length > 0) {
            const selectedAsset = selectedRows[0];
            this.selectedAssetId = selectedAsset.id;
            this.selectedAssetName = selectedAsset.name;
            this.loadCompatibleProducts();
        } else {
            this.selectedAssetId = null;
            this.selectedAssetName = null;
            this.compatibleProducts = [];
        }
    }
    
    async loadAssets() {
        if (!this.recordId) return;
        
        this.isLoading = true;
        try {
            const result = await getAccountAssets({ accountId: this.recordId });
            this.assetData = this.processAssetData(result);
        } catch (error) {
            this.error = error;
            this.showToast('Error', 'Error loading assets: ' + error.body.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }
    
    async loadCompatibleProducts() {
        if (!this.selectedAssetId) return;
        
        this.isLoadingProducts = true;
        try {
            const result = await getCompatibleProductsWithStoreName({
                assetId: this.selectedAssetId,
                webstoreName: this.webstoreName,
                effectiveAccountId: this.effectiveAccountId || this.recordId
            });
            
            this.compatibleProducts = result || [];
            
            if (this.compatibleProducts.length === 0) {
                this.showToast('Info', 'No compatible products found for the selected asset.', 'info');
            }
        } catch (error) {
            this.error = error;
            this.compatibleProducts = [];
            this.showToast('Error', 'Error loading compatible products: ' + error.body.message, 'error');
        } finally {
            this.isLoadingProducts = false;
        }
    }
    
    handleAddToCart(event) {
        const productId = event.detail.productId;
        const quantity = event.detail.quantity;
        
        // Dispatch custom event for parent component to handle cart operations
        this.dispatchEvent(new CustomEvent('addtocart', {
            detail: {
                productId: productId,
                quantity: quantity,
                assetId: this.selectedAssetId,
                assetName: this.selectedAssetName
            }
        }));
        
        this.showToast('Success', 'Product added to cart', 'success');
    }
    
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
    
    get hasAssets() {
        return this.assetData && this.assetData.length > 0;
    }
    
    get hasSelectedAsset() {
        return this.selectedAssetId != null;
    }
    
    get hasCompatibleProducts() {
        return this.compatibleProducts && this.compatibleProducts.length > 0;
    }
    
    get selectedAssetLabel() {
        return this.selectedAssetName ? `Compatible Products for: ${this.selectedAssetName}` : 'Select an Asset';
    }
}