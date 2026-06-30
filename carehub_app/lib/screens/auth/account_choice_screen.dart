import 'package:flutter/material.dart';
import 'auth_widgets.dart';
import 'sign_in_screen.dart';
import 'register_screen.dart';
import 'join_family_screen.dart';

class AccountChoiceScreen extends StatefulWidget {
  const AccountChoiceScreen({super.key});

  @override
  State<AccountChoiceScreen> createState() => _AccountChoiceScreenState();
}

class _AccountChoiceScreenState extends State<AccountChoiceScreen> {
  bool _ownInsurance = true;

  Widget _choiceCard({required String title, required String subtitle, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(selected ? 0.12 : 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? Colors.cyanAccent : Colors.white24, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            Icon(selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? Colors.cyanAccent : Colors.white38),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: authBgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              authLogo(),
              const SizedBox(height: 20),
              const Text('HealthLink',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Join HealthLink today and take the first step towards smarter coverage.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 20),
              const Text('How would you like to join?',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 15)),
              const SizedBox(height: 16),
              _choiceCard(
                title: 'Get My Own Insurance',
                subtitle: 'Start a fresh individual or family plan',
                selected: _ownInsurance,
                onTap: () => setState(() => _ownInsurance = true),
              ),
              const SizedBox(height: 12),
              _choiceCard(
                title: 'Join Existing Family Insurance',
                subtitle: 'Access coverage through an existing member',
                selected: !_ownInsurance,
                onTap: () => setState(() => _ownInsurance = false),
              ),
              const SizedBox(height: 28),
              authPrimaryButton(
                label: 'Continue',
                isLoading: false,
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _ownInsurance ? const RegisterScreen() : const JoinFamilyScreen(),
                  ));
                },
              ),
              const SizedBox(height: 24),
              const Center(child: Text('Already have an account?', style: TextStyle(color: Colors.white54))),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignInScreen())),
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