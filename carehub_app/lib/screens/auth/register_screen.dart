import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../core/api_exception.dart';
import 'auth_widgets.dart';
import 'sign_in_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _gender; // "M" or "F"
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      // Send ISO format (YYYY-MM-DD) to the backend, not a display format.
      _dobController.text =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _dobController.text.trim().isEmpty ||
        _gender == null ||
        _passwordController.text.isEmpty) {
      showAuthError(context, 'Please fill in all fields.');
      return;
    }

    final phone = _phoneController.text.trim();
    if (phone.length != 8 || int.tryParse(phone) == null) {
      showAuthError(context, 'Phone number must be exactly 8 digits.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.registerOwner(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: phone,
        dateOfBirth: _dobController.text.trim(),
        gender: _gender!,
        password: _passwordController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created! Please sign in.')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInScreen()),
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
              authLogo(),
              const SizedBox(height: 16),
              const Text('HealthLink',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text(
                'Join HealthLink today and take the first step towards smarter coverage.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),

              const Text('Full Name', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'Johnathan Doe', icon: Icons.person_outline),
              ),
              const SizedBox(height: 16),

              const Text('Email Address', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'name@example.com', icon: Icons.mail_outline),
              ),
              const SizedBox(height: 16),

              const Text('Phone Number', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 8,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: '8 digits, e.g. 12345678', icon: Icons.phone_outlined)
                    .copyWith(counterText: ''),
              ),
              const SizedBox(height: 16),

              const Text('Date of Birth', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _dobController,
                readOnly: true,
                onTap: _pickDate,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'YYYY-MM-DD', icon: Icons.calendar_today_outlined),
              ),
              const SizedBox(height: 16),

              const Text('Gender', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _gender,
                dropdownColor: authBgColor,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: 'Select Gender', icon: Icons.wc_outlined),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Male', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: 'F', child: Text('Female', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (value) => setState(() => _gender = value),
              ),
              const SizedBox(height: 16),

              const Text('Password', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: authFieldDecoration(hint: '••••••••', icon: Icons.lock_outline),
              ),
              const SizedBox(height: 28),

              authPrimaryButton(label: 'Register Account', isLoading: _isLoading, onPressed: _handleRegister),
              const SizedBox(height: 20),
              const Center(child: Text('Already have an account?', style: TextStyle(color: Colors.white54))),
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
            ],
          ),
        ),
      ),
    );
  }
}