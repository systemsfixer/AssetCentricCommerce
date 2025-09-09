import { LightningElement, api, track, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Id from "@salesforce/user/Id";
import CONTACT_ACCOUNT_ID from "@salesforce/schema/User.Contact.AccountId";
import getAccountAssets from "@salesforce/apex/AssetProductController.getAccountAssets";
import getCompatibleProductsWithStoreName from "@salesforce/apex/AssetProductController.getCompatibleProductsWithStoreName";

const TREE_COLUMNS = [
  {
    label: "Asset Name",
    fieldName: "name",
    type: "text",
    initialWidth: 280,
    cellAttributes: {
      iconName: { fieldName: "iconName" }
    }
  },
  {
    label: "Status",
    fieldName: "status",
    type: "text",
    initialWidth: 120
  },
  {
    label: "Asset Type",
    fieldName: "assetTypeName",
    type: "text",
    initialWidth: 200
  },
  {
    label: "Hierarchy Path",
    fieldName: "hierarchyPath",
    type: "text",
    wrapText: true
  }
];

export default class AssetProductExplorer extends LightningElement {
  @api recordId; // Account ID when used on Account page
  @api webstoreName; // B2B Commerce webstore name (environment portable)
  @api effectiveAccountId; // Account ID for pricing context

  @track assetData = [];
  @track expandedRows = [];
  @track selectedAssetId;
  @track selectedAssetName;
  @track compatibleProducts = [];
  @track isLoading = false;
  @track isLoadingProducts = false;
  @track error;

  treeColumns = TREE_COLUMNS;

  // Wire to get current user's account context in B2B Commerce
  @wire(getRecord, { recordId: Id, fields: [CONTACT_ACCOUNT_ID] })
  currentUser;

  connectedCallback() {
    if (this.recordId) {
      this.loadAssets();
    }
  }

  renderedCallback() {
    // Reload assets if effective record ID becomes available
    if (
      this.effectiveRecordId &&
      this.assetData.length === 0 &&
      !this.isLoading
    ) {
      this.loadAssets();
    }
  }

  get effectiveRecordId() {
    // Priority: recordId property > current user's account > null
    if (this.recordId) {
      return this.recordId;
    }

    // In B2B Commerce, get account from current user's contact
    if (this.currentUser && this.currentUser.data) {
      const userAccountId = getFieldValue(
        this.currentUser.data,
        CONTACT_ACCOUNT_ID
      );
      if (userAccountId) {
        return userAccountId;
      }
    }

    return null;
  }

  @wire(getAccountAssets, { accountId: "$effectiveRecordId" })
  wiredAssets({ error, data }) {
    if (data) {
      this.assetData = this.processAssetData(data);
      this.error = undefined;
    } else if (error) {
      this.error = error;
      this.assetData = [];
      if (error.body && error.body.message) {
        this.showToast(
          "Error",
          "Error loading assets: " + error.body.message,
          "error"
        );
      }
    }
  }

  processAssetData(data) {
    if (!data || !Array.isArray(data)) {
      return [];
    }

    // Set up expanded rows for assets that have children
    const expandedAssetIds = [];

    const processedData = data.map((asset) => {
      const processedAsset = {
        ...asset,
        iconName: this.getAssetIcon(asset.status)
      };

      // If this asset has children, add it to expanded rows
      if (asset.children && asset.children.length > 0) {
        expandedAssetIds.push(asset.id);
        // Recursively process children
        processedAsset.children = this.processChildAssets(asset.children);
      }

      return processedAsset;
    });

    // Update expanded rows
    this.expandedRows = expandedAssetIds;

    return processedData;
  }

  processChildAssets(children) {
    if (!children || !Array.isArray(children)) {
      return [];
    }

    return children.map((child) => ({
      ...child,
      iconName: this.getAssetIcon(child.status),
      children: child.children ? this.processChildAssets(child.children) : []
    }));
  }

  getAssetIcon(status) {
    switch (status) {
      case "Installed":
        return "utility:success";
      case "Shipped":
        return "utility:truck";
      case "Purchased":
        return "utility:shopping_cart";
      default:
        return "utility:asset_object";
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
    const accountId = this.effectiveRecordId;
    if (!accountId) return;

    this.isLoading = true;
    try {
      const result = await getAccountAssets({ accountId: accountId });
      this.assetData = this.processAssetData(result);
    } catch (error) {
      this.error = error;
      if (error.body && error.body.message) {
        this.showToast(
          "Error",
          "Error loading assets: " + error.body.message,
          "error"
        );
      }
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
        effectiveAccountId: this.effectiveAccountId || this.effectiveRecordId
      });

      this.compatibleProducts = result || [];

      if (this.compatibleProducts.length === 0) {
        this.showToast(
          "Info",
          "No compatible products found for the selected asset.",
          "info"
        );
      }
    } catch (error) {
      this.error = error;
      this.compatibleProducts = [];
      this.showToast(
        "Error",
        "Error loading compatible products: " + error.body.message,
        "error"
      );
    } finally {
      this.isLoadingProducts = false;
    }
  }

  handleAddToCart(event) {
    const productId = event.detail.productId;
    const quantity = event.detail.quantity;

    // Dispatch custom event for parent component to handle cart operations
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: {
          productId: productId,
          quantity: quantity,
          assetId: this.selectedAssetId,
          assetName: this.selectedAssetName
        }
      })
    );

    this.showToast("Success", "Product added to cart", "success");
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
    return this.selectedAssetName
      ? `Compatible Products for: ${this.selectedAssetName}`
      : "Select an Asset";
  }
}
