import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agromat_project/providers/cart_provider.dart';
import 'package:agromat_project/services/order_service.dart';
import 'package:agromat_project/models/cart_item.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _phone = '';
  String _address = '';
  String _paymentMethod = 'Pay on Delivery';
  String _momoNumber = '';
  bool _isPlacingOrder = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cartItems = cartProvider.cartItems;
    final total = cartProvider.totalAmount;
    final subtotal = cartItems.fold(
        0.0, (sum, item) => sum + (item.product.price * item.quantity));
    final discount = subtotal - total;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF145A32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF145A32),
              ),
            ),
            const SizedBox(height: 12),
            ...cartItems.map((item) => _buildCartItemRow(item)),
            const Divider(height: 32),
            _buildSummaryRow('Subtotal', subtotal),
            if (discount > 0.01) _buildSummaryRow('Discount', -discount),
            _buildSummaryRow('Total', total, isTotal: true),
            const SizedBox(height: 24),
            Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF145A32),
              ),
            ),
            const SizedBox(height: 8),
            _buildPaymentOptions(),
            if (_paymentMethod == 'Mobile Money') ...[
              const SizedBox(height: 8),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Mobile Money Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (_paymentMethod == 'Mobile Money' &&
                      (value == null || value.isEmpty)) {
                    return 'Enter your MoMo number';
                  }
                  return null;
                },
                onChanged: (value) => _momoNumber = value,
              ),
            ],
            const SizedBox(height: 32),
            Text(
              'Delivery Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF145A32),
              ),
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your name'
                        : null,
                    onSaved: (value) => _name = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your phone number'
                        : null,
                    onSaved: (value) => _phone = value ?? '',
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Delivery Address',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your address'
                        : null,
                    onSaved: (value) => _address = value ?? '',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed:
                        _isPlacingOrder ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isPlacingOrder
                        ? null
                        : () => _placeOrder(context, cartProvider),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF145A32),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isPlacingOrder
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Place Order',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemRow(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.product.name} x${item.quantity}',
              style: const TextStyle(fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '\u20B5${item.totalPrice.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        RadioListTile<String>(
          value: 'Pay on Delivery',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() => _paymentMethod = value!);
          },
          title: const Text('Pay on Delivery'),
        ),
        RadioListTile<String>(
          value: 'Mobile Money',
          groupValue: _paymentMethod,
          onChanged: (value) {
            setState(() => _paymentMethod = value!);
          },
          title: const Text('Mobile Money'),
        ),
      ],
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

  void _placeOrder(BuildContext context, CartProvider cartProvider) async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    if (_paymentMethod == 'Mobile Money' && _momoNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your Mobile Money number.')),
      );
      return;
    }
    setState(() => _isPlacingOrder = true);
    final orderService = OrderService();
    try {
      await orderService.placeOrder(
          cartProvider.cartItems, cartProvider.totalAmount,
          name: _name,
          phone: _phone,
          address: _address,
          paymentMethod: _paymentMethod,
          momoNumber: _paymentMethod == 'Mobile Money' ? _momoNumber : null);
      setState(() => _isPlacingOrder = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Order Placed!'),
          content: const Text('Your order has been placed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Checkout Failed'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
