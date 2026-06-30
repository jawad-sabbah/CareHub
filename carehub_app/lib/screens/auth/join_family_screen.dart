import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/api_exception.dart';
import 'auth_widgets.dart';
import 'sign_in_screen.dart';
import '../home/main_shell.dart';

/// TEMPORARY: hardcoded to match the real `relation` table values
/// confirmed via pgAdmin. If this table ever changes, this list goes
/// stale - a GET /relations endpoint would remove that risk.
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

class JoinFamilyScreen extends StatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  State<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends State<JoinFamilyScreen> {
  final _policyCodeController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _nameController = TextEditingController();
  int? _relationId;
  bool _isLoading = false;

  @override
  void dispose() {
    _policyCodeController.dispose();
    _ownerEmailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleJoin() async {
    if (_policyCodeController.text.trim().isEmpty ||
        _ownerEmailController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _relationId == null) {
      showAuthError(context, 'Please fill in all fields.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.joinFamilyMember(
        policyCode: _policyCodeController.text.trim(),
        ownerEmail: _ownerEmailController.text.trim(),
        fullName: _nameController.text.trim(),
        relationId: _relationId!,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on ApiException catch (e) {
      showAuthError(context, e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: authBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              authLogo(icon: Icons.shield_outlined),
              const SizedBox(height: 16),
              const Text('Join Family Plan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('Connect to an existing policy',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 28),

              const Text('Family Policy ID', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _policyCodeController,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'e.g. CH-VIP-2026-0001', icon: Icons.shield_outlined),
              ),
              const SizedBox(height: 16),

              const Text("Owner's Email", style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _ownerEmailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'owner@example.com', icon: Icons.mail_outline),
              ),
              const SizedBox(height: 16),

              const Text('Your Full Name', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'Johnathan Doe', icon: Icons.person_outline),
              ),
              const SizedBox(height: 16),

              const Text('Relationship', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _relationId,
                dropdownColor: authBgColor,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'Select Relationship', icon: Icons.people_outline),
                items: _relationOptions.entries
                    .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white))))
                    .toList(),
                onChanged: (value) => setState(() => _relationId = value),
              ),
              const SizedBox(height: 28),

              authPrimaryButton(label: 'Request to Join', isLoading: _isLoading, onPressed: _handleJoin),
              const SizedBox(height: 24),
              const Center(child: Text('ALREADY HAVE AN ACCOUNT?', style: TextStyle(color: Colors.white54, fontSize: 12))),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    side: const BorderSide(color: Colors.white38),
                  ),
                  child: const Text('Sign In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.shield, color: Colors.white38, size: 14),
                  SizedBox(width: 4),
                  Text('HIPAA COMPLIANT', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  SizedBox(width: 16),
                  Icon(Icons.lock, color: Colors.white38, size: 14),
                  SizedBox(width: 4),
                  Text('256-BIT ENCRYPTED', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}