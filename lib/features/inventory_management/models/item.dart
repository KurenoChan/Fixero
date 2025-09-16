class Item {
  final String itemId;
  final String itemName;
  final String itemDescription;
  final String itemCategory;
  final String itemSubCategory;
  final double itemPrice;
  final int stockQuantity;
  final String unit;
  final int lowStockThreshold;
  final String imageUrl;

  Item({
    required this.itemId,
    required this.itemName,
    required this.itemDescription,
    required this.itemCategory,
    required this.itemSubCategory,
    required this.itemPrice,
    required this.stockQuantity,
    required this.unit,
    required this.lowStockThreshold,
    required this.imageUrl,
  });

  // To convert Firebase JSON into Item
  factory Item.fromMap(Map<dynamic, dynamic> map, String id) {
    return Item(
      itemId: id,
      itemName: map['itemName'] ?? '',
      itemDescription: map['itemDescription'] ?? '',
      itemCategory: map['itemCategory'] ?? '',
      itemSubCategory: map['itemSubCategory'] ?? '',
      itemPrice: (map['itemPrice'] ?? 0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 0,
      unit: map['unit'] ?? '',
      lowStockThreshold: map['lowStockThreshold'] ?? 0,
      imageUrl: map['itemImageUrl'] ?? '',
    );
  }

  // To convert Item into Firebase JSON
  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemCategory': itemCategory,
      'itemSubCategory': itemSubCategory,
      'itemPrice': itemPrice,
      'stockQuantity': stockQuantity,
      'unit': unit,
      'lowStockThreshold': lowStockThreshold,
      'itemImageUrl': imageUrl,
    };
  }
}