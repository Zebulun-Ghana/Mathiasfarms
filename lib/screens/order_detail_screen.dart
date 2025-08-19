import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailScreen extends StatelessWidget {
  final String userId;
  final String orderId;
  const OrderDetailScreen(
      {super.key, required this.userId, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseFirestore.instance.app.options;
    final currentUser = FirebaseFirestore.instance.app.options;
    final userDoc = FirebaseFirestore.instance.collection('users');
    final orderRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('orders')
        .doc(orderId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF145A32),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: orderRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Order not found.'));
          }
          final data = snapshot.data!.data()!;
          final createdAt = data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
              : DateTime.now();
          final total = (data['total'] ?? 0).toDouble();
          final status = data['status'] ?? 'pending';
          final payment = data['paymentMethod'] ?? 'Pay on Delivery';
          final momoNumber = data['momoNumber'] ?? '';
          final name = data['name'] ?? '';
          final phone = data['phone'] ?? '';
          final address = data['address'] ?? '';
          final items = (data['items'] as List?) ?? [];
          final subtotal = items.fold<double>(
              0.0,
              (sum, item) =>
                  sum +
                  ((item['unitPrice'] ?? item['price'] ?? 0) *
                      (item['quantity'] ?? 1)));
          final discount = subtotal - total;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #$orderId',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Chip(
                      label: Text(
                        status[0].toUpperCase() + status.substring(1),
                        style: TextStyle(
                          color: status == 'completed'
                              ? Colors.green
                              : (status == 'cancelled'
                                  ? Colors.red
                                  : Colors.orange),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: status == 'completed'
                          ? Colors.green[50]
                          : (status == 'cancelled'
                              ? Colors.red[50]
                              : Colors.orange[50]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Placed: ${createdAt.toLocal().toString().split(" ")[0]}'),
                const Divider(height: 32),
                Text('Items',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF145A32))),
                const SizedBox(height: 8),
                ...items.map<Widget>((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name'] ?? ''} x${item['quantity'] ?? 1}',
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '\u20B5${((item['unitPrice'] ?? item['price'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 32),
                _buildSummaryRow('Subtotal', subtotal),
                if (discount > 0.01) _buildSummaryRow('Discount', -discount),
                _buildSummaryRow('Total', total, isTotal: true),
                const SizedBox(height: 24),
                Text('Payment Method',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF145A32))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.payments, color: Color(0xFF145A32)),
                    const SizedBox(width: 12),
                    Text(payment,
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF145A32),
                            fontWeight: FontWeight.w500)),
                    if (payment == 'Mobile Money' && momoNumber.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Text('($momoNumber)',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[700])),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Text('Delivery Information',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF145A32))),
                const SizedBox(height: 8),
                _buildInfoRow('Name', name),
                _buildInfoRow('Phone', phone),
                _buildInfoRow('Address', address),
              ],
            ),
          );
        },
      ),
      backgroundColor: Colors.grey[50],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? const Color(0xFF145A32) : Colors.grey[800],
            ),
          ),
          Text(
            '${value < 0 ? '-' : ''}\u20B5${value.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? const Color(0xFF145A32)
                  : (value < 0 ? Colors.red : Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
