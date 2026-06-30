import 'package:flutter/material.dart';

/// Pure static content - no API call. This is placeholder/sample text
/// for your senior project demo, NOT a real legal document. If this
/// app is ever used with real user data, have this reviewed/written
/// by someone qualified in data privacy law before relying on it.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Privacy Policy', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF1E3FE0)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3FE0), Color(0xFF1652D6)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('LEGAL DOCUMENT', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1)),
                const SizedBox(height: 6),
                const Text('Your Privacy Matters', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Last Updated: Sample Date', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: const Text(
              'This sample Privacy Policy outlines how CareHub would handle '
              'data provided through this app. This is placeholder text for '
              'project demonstration purposes only.',
              style: TextStyle(height: 1.4),
            ),
          ),
          const SizedBox(height: 24),
          _section(
            icon: Icons.bar_chart,
            iconBg: const Color(0xFFE3E9FF),
            title: '1. Information We Collect',
            children: [
              _infoCard('Personal Identity', 'Full name, date of birth, and contact details used to verify your account.'),
              _infoCard('Health Data', 'Medical history, diagnosis codes, and claims information related to your policy.'),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            icon: Icons.badge_outlined,
            iconBg: const Color(0xFFD6F5E3),
            title: '2. How We Use Your Data',
            children: [
              _checkItem('Policy Administration', 'Processing enrollment and managing your insurance benefits.'),
              _checkItem('Claims Processing', 'Verifying medical services and processing provider payments.'),
            ],
          ),
          const SizedBox(height: 20),
          _section(
            icon: Icons.lock_outline,
            iconBg: const Color(0xFFFFE9D6),
            title: '3. Data Security',
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF455A8C), Color(0xFF1E3FE0)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Your data should be protected with strong encryption and regular security audits.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24)
        ],
      ),
    );
  }

  Widget _section({required IconData icon, required Color iconBg, required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(backgroundColor: iconBg, radius: 16, child: Icon(icon, size: 16, color: const Color(0xFF1E3FE0))),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const Divider(height: 20),
        ...children,
      ],
    );
  }

  Widget _infoCard(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(body, style: const TextStyle(color: Colors.black87, height: 1.3)),
        ],
      ),
    );
  }

  Widget _checkItem(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF1E3FE0), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(color: Colors.black87, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}