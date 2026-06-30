import 'package:flutter/material.dart';
import '../../models/profile_data.dart';
import '../../services/profile_service.dart';
import '../../services/auth_service.dart';
import '../../core/api_exception.dart';
import '../auth/account_choice_screen.dart';
import 'personal_information_screen.dart';
import 'contact_us_screen.dart';
import 'privacy_policy_screen.dart';
import '../insurance/insurance_details_screen.dart';

class ProfileHomeScreen extends StatefulWidget {
  const ProfileHomeScreen({super.key});

  @override
  State<ProfileHomeScreen> createState() => _ProfileHomeScreenState();
}

class _ProfileHomeScreenState extends State<ProfileHomeScreen> {
  ProfileData? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final profile = await ProfileService.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );

    if (confirmed != true) return;

    await AuthService.logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AccountChoiceScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('HealthLink', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        leading: const SizedBox(),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFFE8EAF6),
                          child: const Icon(Icons.person, size: 48, color: Color(0xFF1E3FE0)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(_profile!.userName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: Text('Member since account creation',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ),
                      const SizedBox(height: 24),
                      _accountSection(context),
                      const SizedBox(height: 24),
                      const Text('Support', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      _supportSection(context),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _accountSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.person_outline,
            label: 'Personal Information',
            onTap: ()async {
              final updated = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => PersonalInformationScreen(profile: _profile!)),
                );
                if (updated == true) {
                  _load(); 
                }
            }
          ),
          const Divider(height: 1),
          _menuRow(
            icon: Icons.qr_code_2,
            label: 'My Insurance Card',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const InsuranceDetailsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _supportSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _menuRow(
            icon: Icons.mail_outline,
            label: 'Contact Us',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ContactUsScreen()),
            ),
          ),
          const Divider(height: 1),
          _menuRow(
            icon: Icons.shield_outlined,
            label: 'Privacy Policy',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow({required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E3FE0)),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}