class Product {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final String description;
  final String category;
  final bool isFeatured;
  final double? discountPercentage;
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
    this.isFeatured = false,
    this.discountPercentage,
    required this.unit,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      discountPercentage: data['discountPercentage']?.toDouble(),
      unit: data['unit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'category': category,
      'isFeatured': isFeatured,
      'discountPercentage': discountPercentage,
      'unit': unit,
    };
  }
}
