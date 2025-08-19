import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agromat_project/models/product.dart';

class ProductService {
  final _productsRef = FirebaseFirestore.instance.collection('products');

  Future<List<Product>> fetchProducts() async {
    try {
      final snapshot = await _productsRef.get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      rethrow;
    }
  }

  Stream<List<Product>> productsStream() {
    return _productsRef.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => Product.fromMap(doc.id, doc.data()))
        .toList());
  }

  // Admin methods for product management
  Future<String> createProduct(Product product) async {
    final docRef = await _productsRef.add(product.toMap());
    return docRef.id;
  }

  Future<void> updateProduct(String productId, Product product) async {
    await _productsRef.doc(productId).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _productsRef.doc(productId).delete();
  }

  Future<Product?> getProduct(String productId) async {
    final doc = await _productsRef.doc(productId).get();
    if (doc.exists) {
      return Product.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  Future<List<Product>> fetchFeaturedProducts() async {
    try {
      final snapshot =
          await _productsRef.where('isFeatured', isEqualTo: true).get();
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      print('Error fetching featured products: $e');
      rethrow;
    }
  }
}
