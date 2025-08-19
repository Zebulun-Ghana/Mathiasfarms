import 'package:cloud_firestore/cloud_firestore.dart' as cf;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agromat_project/models/order.dart';
import 'package:agromat_project/models/cart_item.dart';
import 'package:agromat_project/services/cart_service.dart';

class OrderService {
  final cf.FirebaseFirestore _firestore = cf.FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CartService _cartService = CartService();

  String? get _userId => _auth.currentUser?.uid;

  cf.CollectionReference<Map<String, dynamic>> get _ordersCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('orders');
  }

  Future<void> placeOrder(
    List<CartItem> items,
    double total, {
    required String name,
    required String phone,
    required String address,
    String paymentMethod = 'Pay on Delivery',
    String? momoNumber,
  }) async {
    if (_userId == null) throw Exception('User not authenticated');
    if (items.isEmpty) throw Exception('Cart is empty');

    final order = Order(
      id: '',
      items: items,
      total: total,
      createdAt: DateTime.now(),
      status: 'pending',
    );
    final orderData = order.toMap();
    orderData['paymentMethod'] = paymentMethod;
    orderData['name'] = name;
    orderData['phone'] = phone;
    orderData['address'] = address;
    orderData['userId'] = _userId;
    if (momoNumber != null && momoNumber.isNotEmpty) {
      orderData['momoNumber'] = momoNumber;
    }

    try {
      await _ordersCollection.add(orderData);
      await _cartService.clearCart();
    } catch (e, stack) {
      print('Order placement error: $e');
      print(stack);
      throw Exception('Failed to place order: $e');
    }
  }
}
