import 'package:flutter/foundation.dart';
import 'package:agromat_project/models/cart_item.dart';
import 'package:agromat_project/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  List<CartItem> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<CartItem> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get itemCount {
    return _cartItems.fold(0, (total, item) => total + item.quantity);
  }

  double get totalAmount {
    return _cartItems.fold(0.0, (total, item) => total + item.totalPrice);
  }

  bool get isEmpty => _cartItems.isEmpty;

  // Initialize cart
  Future<void> loadCart() async {
    _setLoading(true);
    try {
      _cartItems = await _cartService.getCartItems();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Add item to cart
  Future<void> addToCart(CartItem item) async {
    try {
      await _cartService.addToCart(item.product, quantity: item.quantity);
      await loadCart(); // Reload cart to get updated data
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Remove item from cart
  Future<void> removeFromCart(String productId) async {
    try {
      await _cartService.removeFromCart(productId);
      await loadCart(); // Reload cart to get updated data
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String productId, int quantity) async {
    try {
      await _cartService.updateQuantity(productId, quantity);
      await loadCart(); // Reload cart to get updated data
      _error = null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
      _cartItems.clear();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check if product is in cart
  bool isProductInCart(String productId) {
    return _cartItems.any((item) => item.product.id == productId);
  }

  // Get quantity of specific product in cart
  int getProductQuantity(String productId) {
    try {
      final item = _cartItems.firstWhere(
        (item) => item.product.id == productId,
      );
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
