import 'package:flutter/material.dart';
import '../../models/profile_data.dart';
import 'edit_information_screen.dart';
import 'change_password_screen.dart';

class PersonalInformationScreen extends StatelessWidget {
  final ProfileData profile;
  const PersonalInformationScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        title: const Text('Personal Information', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF1E3FE0)),
        actions: [
          TextButton(
            onPressed: () async {
              final updated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(builder: (_) => EditInformationScreen(profile: profile)),
              );
              if (updated == true && context.mounted) {
                Navigator.of(context).pop(); // pop back so ProfileHome reloads fresh data
              }
            },
            child: const Text('Edit', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: ListView(
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
          Center(child: Text(profile.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 24),
          _infoField('FULL NAME', profile.userName),
          _infoField('EMAIL ADDRESS', profile.email),
          _infoField('PHONE NUMBER', profile.phone),
          _infoField('DATE OF BIRTH', profile.dateOfBirth),
          _infoField('GENDER', profile.gender == 'M' ? 'Male' : profile.gender == 'F' ? 'Female' : profile.gender),
          const SizedBox(height: 24),
          const Text('Security Settings', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.lock_outline, color: Color(0xFF1E3FE0)),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoField(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 11, letterSpacing: 0.5)),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 15)),
        ],
      ),
    );
  }
}