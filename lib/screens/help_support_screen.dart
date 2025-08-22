import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF145A32),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQ Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF145A32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFAQItem(
                    'How do I place an order?',
                    'Browse products, add them to your cart, and proceed to checkout. You can pay on delivery or use mobile money.',
                  ),
                  const Divider(),
                  _buildFAQItem(
                    'What payment methods do you accept?',
                    'We accept cash on delivery and mobile money payments (MTN, Vodafone, AirtelTigo).',
                  ),
                  const Divider(),
                  _buildFAQItem(
                    'How long does delivery take?',
                    'Delivery typically takes 1-3 business days within Accra and 3-7 days for other regions.',
                  ),
                  const Divider(),
                  _buildFAQItem(
                    'Can I cancel my order?',
                    'Orders can be cancelled within 2 hours of placement. Contact our support team for assistance.',
                  ),
                  const Divider(),
                  _buildFAQItem(
                    'What if I receive a damaged product?',
                    'Contact us within 24 hours of delivery with photos. We\'ll arrange a replacement or refund.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Contact Support Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF145A32),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Support
                  _buildContactTile(
                    icon: Icons.phone,
                    title: 'Call Us',
                    subtitle: '+233 55 938 4231',
                    onTap: () => _makePhoneCall('+233559384231'),
                    color: Colors.green,
                  ),

                  const Divider(),

                  // WhatsApp Support
                  _buildContactTile(
                    icon: Icons.message,
                    title: 'WhatsApp',
                    subtitle: '0559384231',
                    onTap: () => _openWhatsApp(),
                    color: Colors.green,
                  ),

                  const Divider(),

                  // Email Support
                  _buildContactTile(
                    icon: Icons.email,
                    title: 'Email Us',
                    subtitle: 'support@agromat.com',
                    onTap: () => _sendEmail('support@agromat.com'),
                    color: Colors.blue,
                  ),

                  const Divider(),

                  // Live Chat
                  // _buildContactTile(
                  //   icon: Icons.chat,
                  //   title: 'Live Chat',
                  //   subtitle: 'Available 8AM - 8PM',
                  //   onTap: () => _showLiveChatDialog(context),
                  //   color: Colors.orange,
                  // ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Business Hours
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Hours',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF145A32),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBusinessHourRow('Monday - Friday', '8:00 AM - 8:00 PM'),
                  _buildBusinessHourRow('Saturday', '9:00 AM - 6:00 PM'),
                  _buildBusinessHourRow('Sunday', '10:00 AM - 4:00 PM'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF145A32).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF145A32),
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Emergency support available 24/7 for urgent agricultural supplies',
                            style: TextStyle(
                              color: Color(0xFF145A32),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF145A32),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            answer,
            style: TextStyle(
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF145A32),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFF145A32),
      ),
      onTap: onTap,
    );
  }

  Widget _buildBusinessHourRow(String day, String hours) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF145A32),
            ),
          ),
          Text(
            hours,
            style: TextStyle(
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      // Fallback for web or if URL launcher fails
      print('Could not launch phone call');
    }
  }

  Future<void> _openWhatsApp() async {
    const phoneNumber = '233559384231';
    const message = 'Hello! I need help with my MathiasFarms order.';
    final Uri whatsappUri = Uri.parse(
      'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
    );

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      print('Could not launch WhatsApp');
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Agromat Support Request&body=Hello, I need help with...',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      print('Could not launch email');
    }
  }

  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Live Chat'),
          content: const Text(
            'Our live chat feature is coming soon! For now, please use WhatsApp or call us for immediate assistance.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
