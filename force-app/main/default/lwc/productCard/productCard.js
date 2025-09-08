import { LightningElement, api, track } from "lwc";

export default class ProductCard extends LightningElement {
  @api product;
  @track quantity = 1;

  get productName() {
    return this.product?.productName || "Unknown Product";
  }

  get productFamily() {
    return this.product?.productFamily || "";
  }

  get productDescription() {
    return this.product?.description || "No description available";
  }

  get price() {
    return this.product?.price;
  }

  get hasPrice() {
    return this.price != null && this.price !== undefined;
  }

  get formattedPrice() {
    if (this.hasPrice) {
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD"
      }).format(this.price);
    }
    return "Price not available";
  }

  get totalPrice() {
    if (this.hasPrice) {
      return this.price * this.quantity;
    }
    return 0;
  }

  get formattedTotalPrice() {
    if (this.hasPrice) {
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD"
      }).format(this.totalPrice);
    }
    return "Price not available";
  }

  get productFamilyIcon() {
    if (!this.productFamily) return "utility:product";

    switch (this.productFamily.toLowerCase()) {
      case "consumables":
        return "utility:bucket";
      case "accessories":
        return "utility:connected_apps";
      case "parts":
        return "utility:settings";
      case "supplies":
        return "utility:package";
      default:
        return "utility:product";
    }
  }

  get productFamilyVariant() {
    if (!this.productFamily) return "base";

    switch (this.productFamily.toLowerCase()) {
      case "consumables":
        return "warning";
      case "accessories":
        return "success";
      case "parts":
        return "error";
      case "supplies":
        return "inverse";
      default:
        return "base";
    }
  }

  get isMinQuantity() {
    return this.quantity <= 1;
  }

  get isMaxQuantity() {
    return this.quantity >= 999;
  }

  get showTotalPrice() {
    return this.hasPrice && this.quantity > 1;
  }

  handleQuantityChange(event) {
    const newQuantity = parseInt(event.target.value, 10);
    if (newQuantity > 0 && newQuantity <= 999) {
      this.quantity = newQuantity;
    } else {
      // Reset to previous valid value
      event.target.value = this.quantity;
    }
  }

  handleAddToCart() {
    this.dispatchEvent(
      new CustomEvent("addtocart", {
        detail: {
          productId: this.product.productId,
          productName: this.productName,
          quantity: this.quantity,
          unitPrice: this.price,
          totalPrice: this.totalPrice
        }
      })
    );
  }

  handleIncreaseQuantity() {
    if (this.quantity < 999) {
      this.quantity += 1;
    }
  }

  handleDecreaseQuantity() {
    if (this.quantity > 1) {
      this.quantity -= 1;
    }
  }
}
