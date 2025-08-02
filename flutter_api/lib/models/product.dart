class Product {
  final int productId;
  final String productName;
  final double price;
  final int stock;

  Product({
    required this.productId,
    required this.productName,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      price: _parseToDouble(json['price']),
      stock: json['stock'] as int,
    );
  }

  static double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.parse(value.replaceAll(',', '.'));
    }
    throw FormatException('Invalid price value: $value');
  }

  Map<String, dynamic> toJson() => {
    'productName': productName,
    'price': price,
    'stock': stock,
  };
}