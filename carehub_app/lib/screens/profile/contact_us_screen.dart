import 'package:flutter/material.dart';
import '../../services/contact_service.dart';
import '../../core/api_exception.dart';

/// The "Subject" dropdown is purely UI sugar - the backend just takes
/// whatever string is sent as `subject`, there's no fixed enum on the
/// server side. Feel free to add/remove options here without touching
/// any backend code.
const _subjectOptions = [
  'General Inquiry',
  'Billing Question',
  'Claim Issue',
  'Technical Problem',
  'Other',
];

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  String _subject = _subjectOptions.first;
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _handleSubmit() async {
    if (_messageController.text.trim().isEmpty) {
      _showError('Please enter a message.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ContactService.sendMessage(
        subject: _subject,
        message: _messageController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent! Our support team will get back to you soon.')),
      );
      _messageController.clear();
    } on ApiException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Contact Us', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF1E3FE0)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFE3E9FF), borderRadius: BorderRadius.circular(14)),
            child: const Text(
              'We are a remote-first company dedicated to your health and wellness.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF1E3FE0)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('HOW CAN WE HELP?', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 12),
          _contactCard(
            icon: Icons.call_outlined,
            iconBg: const Color(0xFFE3E9FF),
            iconColor: const Color(0xFF1E3FE0),
            title: 'Call Support',
            lines: const ['+961 7895021'],
          ),
          const SizedBox(height: 12),
          _contactCard(
            icon: Icons.mail_outline,
            iconBg: const Color(0xFFFFE9D6),
            iconColor: const Color(0xFFE08A2B),
            title: 'Email Us',
            lines: const ['carehub.support12@gmail.com'],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Send us a message', style: TextStyle(color: Color(0xFF1E3FE0), fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Subject', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _subject,
                  decoration: _fieldDecoration(),
                  items: _subjectOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _subject = value);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Message', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _messageController,
                  maxLines: 5,
                  decoration: _fieldDecoration().copyWith(hintText: 'How can we assist you today?'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3FE0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : const Icon(Icons.send, color: Colors.white, size: 18),
                    label: const Text('Submit Message', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required List<String> lines,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: iconBg, child: Icon(icon, color: iconColor)),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              ...lines.map((l) => Text(l, style: const TextStyle(color: Color(0xFF1E3FE0)))),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}