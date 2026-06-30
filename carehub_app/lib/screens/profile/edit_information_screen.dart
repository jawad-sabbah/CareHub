import 'package:flutter/material.dart';
import '../../models/profile_data.dart';
import '../../services/profile_service.dart';
import '../../core/api_exception.dart';

class EditInformationScreen extends StatefulWidget {
  final ProfileData profile;
  const EditInformationScreen({super.key, required this.profile});

  @override
  State<EditInformationScreen> createState() => _EditInformationScreenState();
}

class _EditInformationScreenState extends State<EditInformationScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String? _gender;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.userName);
    _emailController = TextEditingController(text: widget.profile.email);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _gender = widget.profile.gender.isNotEmpty ? widget.profile.gender : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _handleSave() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _gender == null) {
      _showError('Please fill in all fields.');
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.length != 8 || int.tryParse(phone) == null) {
      _showError('Phone number must be exactly 8 digits.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ProfileService.updateProfile(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: phone,
        gender: _gender!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.of(context).pop(true); // signal caller to refresh
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
        title: const Text('Edit Information', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: const Text('Save', style: TextStyle(color: Color(0xFF1E3FE0), fontWeight: FontWeight.bold)),
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
          Center(child: Text(widget.profile.userName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          const SizedBox(height: 24),

          const Text('Full Name', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: _nameController, decoration: _fieldDecoration()),
          const SizedBox(height: 16),

          const Text('Email Address', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _fieldDecoration()),
          const SizedBox(height: 16),

          const Text('Phone Number', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 8,
              decoration: _fieldDecoration().copyWith(counterText: '')),
          const SizedBox(height: 16),

          const Text('Gender', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: _gender,
            decoration: _fieldDecoration(),
            items: const [
              DropdownMenuItem(value: 'M', child: Text('Male')),
              DropdownMenuItem(value: 'F', child: Text('Female')),
            ],
            onChanged: (value) => setState(() => _gender = value),
          ),
          const SizedBox(height: 28),

          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3FE0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}