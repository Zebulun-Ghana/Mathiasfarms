import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:agromat_project/models/cart_item.dart';
import 'package:agromat_project/models/product.dart';
import 'package:agromat_project/services/product_service.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  // Get cart collection reference
  CollectionReference<Map<String, dynamic>> get _cartCollection {
    if (_userId == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(_userId).collection('cart');
  }

  // Add item to cart
  Future<void> addToCart(Product product, {int quantity = 1}) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      // Check if item already exists in cart
      final existingDoc = await _cartCollection.doc(product.id).get();

      if (existingDoc.exists) {
        // Update quantity if item exists
        final currentQuantity = existingDoc.data()?['quantity'] ?? 0;
        await _cartCollection.doc(product.id).update({
          'quantity': currentQuantity + quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Add new item to cart
        await _cartCollection.doc(product.id).set({
          'productId': product.id,
          'quantity': quantity,
          'addedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to add item to cart: $e');
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _cartCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to remove item from cart: $e');
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      if (quantity <= 0) {
        await removeFromCart(productId);
      } else {
        await _cartCollection.doc(productId).update({
          'quantity': quantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to update quantity: $e');
    }
  }

  // Get all cart items
  Future<List<CartItem>> getCartItems() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final querySnapshot = await _cartCollection.get();
      final cartItems = <CartItem>[];

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final productId = data['productId'] as String;

        // Fetch product details
        final product = await ProductService().getProduct(productId);
        if (product != null) {
          cartItems.add(CartItem.fromMap(data, product));
        }
      }

      // Sort by added date (newest first)
      cartItems.sort((a, b) => b.addedAt.compareTo(a.addedAt));
      return cartItems;
    } catch (e) {
      throw Exception('Failed to get cart items: $e');
    }
  }

  // Get cart item count
  Future<int> getCartItemCount() async {
    if (_userId == null) return 0;

    try {
      final querySnapshot = await _cartCollection.get();
      int totalCount = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        totalCount += (data['quantity'] ?? 0) as int;
      }

      return totalCount;
    } catch (e) {
      return 0;
    }
  }

  // Get cart total
  Future<double> getCartTotal() async {
    if (_userId == null) return 0.0;

    try {
      final cartItems = await getCartItems();
      double total = 0.0;
      for (final item in cartItems) {
        total += item.totalPrice;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Clear entire cart
  Future<void> clearCart() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final querySnapshot = await _cartCollection.get();
      final batch = _firestore.batch();

      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: $e');
    }
  }

  // Check if product is in cart
  Future<bool> isProductInCart(String productId) async {
    if (_userId == null) return false;

    try {
      final doc = await _cartCollection.doc(productId).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get quantity of specific product in cart
  Future<int> getProductQuantity(String productId) async {
    if (_userId == null) return 0;

    try {
      final doc = await _cartCollection.doc(productId).get();
      return doc.data()?['quantity'] ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
