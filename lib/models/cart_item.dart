import 'package:agromat_project/models/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final Product product;
  final int quantity;
  final DateTime addedAt;

  CartItem({
    required this.product,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice {
    if (product.discountPercentage != null) {
      final discountedPrice =
          product.price * (1 - product.discountPercentage! / 100);
      return discountedPrice * quantity;
    }
    return product.price * quantity;
  }

  double get unitPrice {
    if (product.discountPercentage != null) {
      return product.price * (1 - product.discountPercentage! / 100);
    }
    return product.price;
  }

  factory CartItem.fromMap(Map<String, dynamic> data, Product product) {
    return CartItem(
      product: product,
      quantity: data['quantity'] ?? 1,
      addedAt: data['addedAt'] is Timestamp
          ? (data['addedAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['addedAt']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'name': product.name,
      'unitPrice': unitPrice,
      'price': product.price,
      'discountPercentage': product.discountPercentage,
      'quantity': quantity,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}
