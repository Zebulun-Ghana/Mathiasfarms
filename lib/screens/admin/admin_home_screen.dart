import 'package:flutter/material.dart';
import 'package:agromat_project/services/product_service.dart';
import 'package:agromat_project/models/product.dart';
import 'package:agromat_project/screens/admin/product_form_screen.dart';
import 'package:agromat_project/screens/admin/admin_profile_screen.dart';
import 'package:agromat_project/screens/product_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agromat_project/models/order.dart' as app_models;
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

// Placeholder screens for reports and users
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: const Center(child: Text('Reports coming soon...')),
    );
  }
}

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      body: const Center(child: Text('User management coming soon...')),
    );
  }
}

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // TODO: Implement search/filter logic
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }
                final users = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final data = users[i].data() as Map<String, dynamic>;
                    final name = data['name'] ?? 'Unknown';
                    final email = data['email'] ?? 'No email';
                    final role = data['role'] ?? 'customer';
                    DateTime? createdAt;
                    if (data['createdAt'] != null) {
                      if (data['createdAt'] is Timestamp) {
                        createdAt = (data['createdAt'] as Timestamp).toDate();
                      } else if (data['createdAt'] is String) {
                        createdAt = DateTime.tryParse(data['createdAt']);
                      }
                    }
                    return ListTile(
                      leading:
                          const Icon(Icons.person, color: Color(0xFF145A32)),
                      title: Text(name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email, style: const TextStyle(fontSize: 13)),
                          Text('Role: $role',
                              style: const TextStyle(fontSize: 13)),
                          if (createdAt != null)
                            Text(
                                'Joined: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetailScreen(
                              userId: users[i].id,
                              userData: data,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserDetailScreen extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> userData;
  const UserDetailScreen(
      {super.key, required this.userId, required this.userData});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  late String _role;
  bool _isUpdating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _role = widget.userData['role'] ?? 'customer';
  }

  Future<void> _updateRole(String newRole) async {
    setState(() {
      _isUpdating = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'role': newRole});
      setState(() {
        _role = newRole;
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role updated to $newRole')),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update role: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deleteUser() async {
    setState(() {
      _isDeleting = true;
    });
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .delete();
      if (mounted) {
        Navigator.pop(context); // Close detail screen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _isDeleting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete user: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userData;
    final createdAt = user['createdAt'] is Timestamp
        ? (user['createdAt'] as Timestamp).toDate()
        : (user['createdAt'] is String
            ? DateTime.tryParse(user['createdAt'])
            : null);
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user['name'] ?? 'Unknown'}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Email: ${user['email'] ?? 'No email'}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Role:', style: const TextStyle(fontSize: 16)),
            Row(
              children: [
                DropdownButton<String>(
                  value: _role,
                  icon: const Icon(Icons.arrow_drop_down),
                  elevation: 2,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.black),
                  underline: Container(),
                  onChanged: _isUpdating
                      ? null
                      : (String? newValue) {
                          if (newValue != null && newValue != _role) {
                            _updateRole(newValue);
                          }
                        },
                  items: <String>['customer', 'admin', 'staff']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                ),
                if (_isUpdating) const SizedBox(width: 12),
                if (_isUpdating)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (createdAt != null)
              Text(
                  'Joined: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: const TextStyle(fontSize: 15)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _isDeleting
                  ? null
                  : () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete User'),
                          content: const Text(
                              'Are you sure you want to delete this user? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteUser();
                              },
                              child: const Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
              icon: const Icon(Icons.delete, color: Colors.white),
              label: const Text('Delete User'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String orderId;
  const OrderDetailsScreen(
      {super.key, required this.orderData, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  late String _status;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _status = widget.orderData['status'] ?? 'pending';
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isUpdating = true;
    });
    try {
      final userId = widget.orderData['userId'];
      if (userId == null) throw Exception('User ID not found for this order.');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(widget.orderId)
          .update({'status': newStatus});
      setState(() {
        _status = newStatus;
        _isUpdating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order status updated to $newStatus')),
        );
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'shipped':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderData = widget.orderData;
    final items = (orderData['items'] as List?) ?? [];
    final createdAt = orderData['createdAt'] is Timestamp
        ? (orderData['createdAt'] as Timestamp).toDate()
        : (orderData['createdAt'] is String
            ? DateTime.tryParse(orderData['createdAt'])
            : null);
    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.orderId}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Order Status: ',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(_status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _status,
                    style: TextStyle(
                      color: _statusColor(_status),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                DropdownButton<String>(
                  value: _status,
                  icon: const Icon(Icons.arrow_drop_down),
                  elevation: 2,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _statusColor(_status)),
                  underline: Container(),
                  onChanged: _isUpdating
                      ? null
                      : (String? newValue) {
                          if (newValue != null && newValue != _status) {
                            _updateStatus(newValue);
                          }
                        },
                  items: <String>[
                    'pending',
                    'processing',
                    'shipped',
                    'delivered'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(color: _statusColor(value))),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Customer Information',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Divider(),
            Text('Name: ${orderData['name'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 15)),
            if (orderData['email'] != null)
              Text('Email: ${orderData['email']}',
                  style: TextStyle(fontSize: 15)),
            if (orderData['phone'] != null)
              Text('Phone: ${orderData['phone']}',
                  style: TextStyle(fontSize: 15)),
            if (orderData['address'] != null)
              Text('Address: ${orderData['address']}',
                  style: TextStyle(fontSize: 15)),
            const SizedBox(height: 20),
            Text('Order Details',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Divider(),
            if (orderData['paymentMethod'] != null)
              Text('Payment: ${orderData['paymentMethod']}',
                  style: TextStyle(fontSize: 15)),
            if (createdAt != null)
              Text(
                  'Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                  style: TextStyle(fontSize: 15)),
            Text('Total: \u20B5${(orderData['total'] ?? 0).toStringAsFixed(2)}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Text('Items',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const Divider(),
            ...items.map((item) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(item['name'] ?? 'Product',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      'Quantity: ${item['quantity']}, Price: \u20B5${item['price']}',
                      style: TextStyle()),
                  trailing: Text(
                      'Total: \u20B5${((item['quantity'] ?? 1) * (item['price'] ?? 0)).toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            }),
            if (_isUpdating)
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}

class OrderManagementScreen extends StatelessWidget {
  const OrderManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Management'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by customer or order ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // TODO: Implement search/filter logic
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('orders')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No orders found.'));
                }
                final orders = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final data = orders[i].data() as Map<String, dynamic>;
                    final id = orders[i].id;
                    final total = (data['total'] ?? 0).toDouble();
                    final status = data['status'] ?? 'pending';
                    DateTime? createdAt;
                    if (data['createdAt'] != null) {
                      if (data['createdAt'] is Timestamp) {
                        createdAt = (data['createdAt'] as Timestamp).toDate();
                      } else if (data['createdAt'] is String) {
                        createdAt = DateTime.tryParse(data['createdAt']);
                      }
                    }
                    final name = data['name'] ?? 'Unknown';
                    return ListTile(
                      leading: const Icon(Icons.receipt_long,
                          color: Color(0xFF145A32)),
                      title: Text('Order #$id',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: $name',
                              style: TextStyle(fontSize: 13)),
                          Text('Total: \u20B5${total.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 13)),
                          if (createdAt != null)
                            Text(
                                'Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: status == 'completed'
                              ? Colors.green.withOpacity(0.15)
                              : status == 'cancelled'
                                  ? Colors.red.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == 'completed'
                                ? Colors.green
                                : status == 'cancelled'
                                    ? Colors.red
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(
                              orderData: data,
                              orderId: id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesManagementScreen extends StatefulWidget {
  const CategoriesManagementScreen({super.key});

  @override
  State<CategoriesManagementScreen> createState() =>
      _CategoriesManagementScreenState();
}

class _CategoriesManagementScreenState
    extends State<CategoriesManagementScreen> {
  bool _isDialogLoading = false;
  XFile? _pickedImage;
  String? _imageUrl;

  Future<String?> _uploadImage(XFile image) async {
    final ref = FirebaseStorage.instance.ref().child(
        'category_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}');
    await ref.putData(await image.readAsBytes());
    return await ref.getDownloadURL();
  }

  Future<void> _showCategoryDialog(
      {String? categoryId,
      String? initialName,
      String? initialDesc,
      String? initialImageUrl}) async {
    final nameController = TextEditingController(text: initialName ?? '');
    final descController = TextEditingController(text: initialDesc ?? '');
    String? errorText;
    bool isEdit = categoryId != null;
    XFile? pickedImage;
    String? imageUrl = initialImageUrl;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickImage() async {
              final picker = ImagePicker();
              final img = await picker.pickImage(
                  source: ImageSource.gallery, imageQuality: 70);
              if (img != null) {
                setState(() {
                  pickedImage = img;
                });
              }
            }

            return AlertDialog(
              title: Text(isEdit ? 'Edit Category' : 'Add Category'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: _isDialogLoading ? null : pickImage,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: pickedImage != null
                            ? Image.file(
                                File(pickedImage!.path),
                                fit: BoxFit.cover,
                              )
                            : (imageUrl != null && imageUrl.isNotEmpty)
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : const Icon(Icons.add_a_photo,
                                    size: 32, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        errorText: errorText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                          labelText: 'Description (optional)'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      _isDialogLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isDialogLoading
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final desc = descController.text.trim();
                          if (name.isEmpty) {
                            setState(() {
                              errorText = 'Name is required';
                            });
                            return;
                          }
                          setState(() {
                            _isDialogLoading = true;
                          });
                          String? uploadedUrl = imageUrl;
                          if (pickedImage != null) {
                            uploadedUrl = await _uploadImage(pickedImage!);
                          }
                          try {
                            if (isEdit) {
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .doc(categoryId)
                                  .update({
                                'name': name,
                                'description': desc,
                                'imageUrl': uploadedUrl ?? '',
                              });
                            } else {
                              await FirebaseFirestore.instance
                                  .collection('categories')
                                  .add({
                                'name': name,
                                'description': desc,
                                'imageUrl': uploadedUrl ?? '',
                                'createdAt': DateTime.now().toIso8601String(),
                              });
                            }
                            if (mounted) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(isEdit
                                      ? 'Category updated'
                                      : 'Category created')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: Colors.red),
                            );
                          }
                          setState(() {
                            _isDialogLoading = false;
                          });
                        },
                  child: _isDialogLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isEdit ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteCategory(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(id)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories Management')),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('categories')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No categories found.'));
            }
            final categories = snapshot.data!.docs;
            return ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final data = categories[i].data() as Map<String, dynamic>;
                final id = categories[i].id;
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    leading: data['imageUrl'] != null &&
                            data['imageUrl'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              data['imageUrl'],
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
                          ),
                    title: Text(data['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: data['description'] != null &&
                            data['description'].toString().isNotEmpty
                        ? Text(data['description'])
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showCategoryDialog(
                            categoryId: id,
                            initialName: data['name'],
                            initialDesc: data['description'],
                            initialImageUrl: data['imageUrl'],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Category'),
                                content: const Text(
                                    'Are you sure you want to delete this category?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteCategory(id);
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: const Color(0xFF145A32),
        tooltip: 'Add Category',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class ProductManagementScreen extends StatelessWidget {
  const ProductManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Management'),
        backgroundColor: const Color(0xFF145A32),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or category',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                // TODO: Implement search/filter logic
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products found.'));
                }
                final products = snapshot.data!.docs;
                return ListView.separated(
                  itemCount: products.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final data = products[i].data() as Map<String, dynamic>;
                    final id = products[i].id;
                    return ListTile(
                      leading: data['imageUrl'] != null &&
                              data['imageUrl'].toString().isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                data['imageUrl'],
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child:
                                  const Icon(Icons.image, color: Colors.grey),
                            ),
                      title: Text(data['name'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(data['category'] ?? ''),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductFormScreen(
                                    product: Product.fromMap(id, data),
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Product'),
                                  content: const Text(
                                      'Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Delete',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await ProductService().deleteProduct(id);
                              }
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                                product: Product.fromMap(id, data)),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProductFormScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF145A32),
        tooltip: 'Add Product',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;
  int? _ordersCount;
  int? _usersCount;
  int? _productsCount;
  bool _isDashboardLoading = true;
  List<app_models.Order> _recentOrders = [];
  static const List<Widget> _pages = [
    Center(child: Text('Orders')),
    AdminProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isDashboardLoading = true;
    });
    try {
      final productsSnap =
          await FirebaseFirestore.instance.collection('products').get();
      final usersSnap =
          await FirebaseFirestore.instance.collection('users').get();
      final ordersSnap =
          await FirebaseFirestore.instance.collectionGroup('orders').get();
      final recentOrdersSnap = await FirebaseFirestore.instance
          .collectionGroup('orders')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();
      setState(() {
        _productsCount = productsSnap.size;
        _usersCount = usersSnap.size;
        _ordersCount = ordersSnap.size;
        _recentOrders = recentOrdersSnap.docs
            .map((doc) => app_models.Order.fromMap(doc.id, doc.data(), []))
            .toList();
        _isDashboardLoading = false;
      });
    } catch (e) {
      setState(() {
        _productsCount = null;
        _usersCount = null;
        _ordersCount = null;
        _recentOrders = [];
        _isDashboardLoading = false;
      });
    }
  }

  Widget _buildDashboardTab() {
    if (_isDashboardLoading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFF145A32)));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Admin Dashboard',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF145A32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome back, here’s an overview of your platform.',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          // Quick Actions
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.add_box_rounded,
                      label: 'Products',
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ProductManagementScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.list_alt_rounded,
                      label: 'Manage Orders',
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const OrderManagementScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.people_alt_rounded,
                      label: 'Manage Users',
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const UserManagementScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.settings,
                      label: 'Settings',
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AdminProfileScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Statistics Cards
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            children: [
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collectionGroup('orders')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildStatCard(
                        icon: Icons.shopping_bag,
                        label: 'Orders',
                        value: 0,
                        color: Colors.blue,
                        isLoading: true);
                  }
                  final count = snapshot.hasData ? snapshot.data!.size : 0;
                  return _buildStatCard(
                      icon: Icons.shopping_bag,
                      label: 'Orders',
                      value: count.toDouble(),
                      color: Colors.blue);
                },
              ),
              StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildStatCard(
                        icon: Icons.people,
                        label: 'Users',
                        value: 0,
                        color: Colors.green,
                        isLoading: true);
                  }
                  final count = snapshot.hasData ? snapshot.data!.size : 0;
                  return _buildStatCard(
                      icon: Icons.people,
                      label: 'Users',
                      value: count.toDouble(),
                      color: Colors.green);
                },
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildStatCard(
                        icon: Icons.inventory_2,
                        label: 'Products',
                        value: 0,
                        color: Colors.orange,
                        isLoading: true);
                  }
                  final count = snapshot.hasData ? snapshot.data!.size : 0;
                  return _buildStatCard(
                      icon: Icons.inventory_2,
                      label: 'Products',
                      value: count.toDouble(),
                      color: Colors.orange);
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Trends Chart
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sales Trends',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF145A32),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true, drawVerticalLine: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            FlSpot(0, 3),
                            FlSpot(1, 4),
                            FlSpot(2, 6),
                            FlSpot(3, 5),
                            FlSpot(4, 8),
                            FlSpot(5, 7),
                            FlSpot(6, 10),
                          ],
                          isCurved: true,
                          color: const Color(0xFF145A32),
                          barWidth: 4,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Recent Orders Table
          Text(
            'Recent Orders',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF145A32),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collectionGroup('orders')
                .limit(5)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                print(
                    'Recent Orders Query: count = ${snapshot.data!.docs.length}');
                for (var doc in snapshot.data!.docs) {
                  print('Order doc: id=${doc.id}, data=${doc.data()}');
                }
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No recent orders.', style: TextStyle());
              }
              final orders = snapshot.data!.docs;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final data = orders[i].data() as Map<String, dynamic>;
                    final id = orders[i].id;
                    final total = (data['total'] ?? 0).toDouble();
                    final status = data['status'] ?? 'pending';
                    DateTime? createdAt;
                    if (data['createdAt'] != null) {
                      if (data['createdAt'] is Timestamp) {
                        createdAt = (data['createdAt'] as Timestamp).toDate();
                      } else if (data['createdAt'] is String) {
                        createdAt = DateTime.tryParse(data['createdAt']);
                      }
                    }
                    final name = data['name'] ?? 'Unknown';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            const Color(0xFF145A32).withOpacity(0.1),
                        child: const Icon(Icons.receipt_long,
                            color: Color(0xFF145A32)),
                      ),
                      title: Text('Order #$id',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer: $name',
                              style: TextStyle(fontSize: 13)),
                          Text('Total: \u20B5${total.toStringAsFixed(2)}',
                              style: TextStyle(fontSize: 13)),
                          if (createdAt != null)
                            Text('Date: ${_formatDate(createdAt)}',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: status == 'completed'
                              ? Colors.green.withOpacity(0.15)
                              : status == 'cancelled'
                                  ? Colors.red.withOpacity(0.15)
                                  : Colors.orange.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: status == 'completed'
                                ? Colors.green
                                : status == 'cancelled'
                                    ? Colors.red
                                    : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    bool isLoading = false,
  }) {
    return Container(
      height: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: value),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, val, _) => Text(
                    val.toInt().toString(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    // Replaced by dashboard
    return _buildDashboardTab();
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.grey[100]!,
                            Colors.grey[200]!,
                          ],
                        ),
                      ),
                      child: product.imageUrl.isNotEmpty
                          ? Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.image,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                );
                              },
                            )
                          : Icon(
                              Icons.image,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                    ),
                  ),
                  // Featured badge
                  if (product.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.amber, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 12,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Featured',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF145A32),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\u20B5${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF145A32),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductFormScreen(
                                    product: product,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF145A32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showDeleteDialog(product),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Delete',
                              style: TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(Product product) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: Text('Are you sure you want to delete "${product.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ProductService().deleteProduct(product.id);
                  setState(() {}); // Refresh the list
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error deleting product: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? AppBar(
              title: const Text('Admin Dashboard'),
              backgroundColor: const Color(0xFF145A32),
              foregroundColor: Colors.white,
              elevation: 0,
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF145A32),
          unselectedItemColor: Colors.grey[600],
          currentIndex: _selectedIndex,
          onTap: (i) => setState(() => _selectedIndex = i),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              activeIcon: Icon(Icons.shopping_bag),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        // Orders tab: show OrderManagementScreen
        return OrderManagementScreen();
      case 2:
        return const CategoriesManagementScreen();
      case 3:
        return _pages[1]; // Profile
      default:
        return _buildHomeTab();
    }
  }
}
