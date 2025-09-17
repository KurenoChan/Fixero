class Item {
  final String itemID;
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
    required this.itemID,
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

  Item copyWith({
    String? itemID,
    String? itemName,
    String? itemDescription,
    String? itemCategory,
    String? itemSubCategory,
    double? itemPrice,
    int? stockQuantity,
    String? unit,
    int? lowStockThreshold,
    String? imageUrl,
  }) {
    return Item(
      itemID: itemID ?? this.itemID,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      itemCategory: itemCategory ?? this.itemCategory,
      itemSubCategory: itemSubCategory ?? this.itemSubCategory,
      itemPrice: itemPrice ?? this.itemPrice,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      unit: unit ?? this.unit,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // To convert Firebase JSON into Item
  factory Item.fromMap(Map<dynamic, dynamic> map, String id) {
    return Item(
      itemID: id,
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