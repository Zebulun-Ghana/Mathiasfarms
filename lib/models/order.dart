import 'package:agromat_project/models/cart_item.dart';

class Order {
  final String id;
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String status; // e.g., 'pending', 'completed', 'cancelled'

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'items': items.map((item) => item.toMap()).toList(),
      'total': total,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Order.fromMap(
      String id, Map<String, dynamic> data, List<CartItem> items) {
    return Order(
      id: id,
      items: items,
      total: (data['total'] ?? 0).toDouble(),
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      status: data['status'] ?? 'pending',
    );
  }
}
