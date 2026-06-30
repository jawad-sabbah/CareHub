import 'package:flutter/material.dart';
import '../../services/family_service.dart';
import '../../core/api_exception.dart';

/// Matches the real `relation` table values (confirmed via pgAdmin).
const _relationOptions = <int, String>{
  1: 'Father',
  2: 'Mother',
  3: 'Son',
  4: 'Daughter',
  5: 'Spouse',
  6: 'Brother',
  7: 'Sister',
  8: 'Grandfather',
  9: 'Grandmother',
  10: 'Other',
};

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  int? _relationId;
  String? _gender; // "M" or "F" - properly scoped as state now
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2010, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleSendInvite() async {
    if (_nameController.text.trim().isEmpty ||
        _relationId == null ||
        _gender == null ||
        _dobController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
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
      await FamilyService.inviteFamilyMember(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: phone,
        dateOfBirth: _dobController.text.trim(),
        gender: _gender!,
        relationId: _relationId!,
      );
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invite Created'),
          content: Text(
            '${_nameController.text.trim()} has been added to your policy.\n\n'
            'There is no automatic email yet - let them know their temporary '
            'password is their phone number, and have them use "Join Family Plan" '
            'with your email and the policy code to activate their account.',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Got it'))],
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
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
        title: const Text('Add Family Member', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Invite a family member to your plan.',
              style: TextStyle(color: Color(0xFF1E3FE0), fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text('Coverage is better together. Fill out the details below to extend your health benefits to your loved ones.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(controller: _nameController, decoration: _fieldDecoration(hint: 'Enter legal name')),
                const SizedBox(height: 16),

                const Text('Relationship', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: _relationId,
                  decoration: _fieldDecoration(hint: 'Select relation'),
                  items: _relationOptions.entries
                      .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (value) => setState(() => _relationId = value),
                ),
                const SizedBox(height: 16),

                const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: _fieldDecoration(hint: 'Select gender'),
                  items: const [
                    DropdownMenuItem(value: 'M', child: Text('Male')),
                    DropdownMenuItem(value: 'F', child: Text('Female')),
                  ],
                  onChanged: (value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 16),

                const Text('Date of Birth', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: _fieldDecoration(hint: 'mm/dd/yyyy').copyWith(suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18)),
                ),
                const SizedBox(height: 16),

                const Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _fieldDecoration(hint: 'name@example.com')),
                const SizedBox(height: 16),

                const Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                TextField(controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 8,
                    decoration: _fieldDecoration(hint: '8 digits, e.g. 12345678').copyWith(counterText: '')),
                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3FF),
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(left: BorderSide(color: Color(0xFF1E3FE0), width: 4)),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF1E3FE0), size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Adding a family member creates their account immediately. '
                          'Share the policy code and your email with them so they can '
                          'activate their access using "Join Family Plan."',
                          style: TextStyle(fontSize: 13, color: Color(0xFF1E3FE0)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _handleSendInvite,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3FE0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Icon(Icons.send, color: Colors.white, size: 18),
              label: const Text('Send Invite', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
    );
  }
}