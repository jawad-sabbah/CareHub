import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../widgets/burst_logo.dart';
import 'account_choice_screen.dart';
import 'sign_in_screen.dart';

/// First screen the user sees. Introduces the product and routes to either
/// account creation or sign-in.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToNewAccount(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AccountChoiceScreen()),
    );
  }

  void _goToSignIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _BackgroundCurvesPainter()),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const BurstLogo(size: 150),
                  const Spacer(),
                  const Text('Smart\nInsurance\nhere!', style: AppTheme.display),
                  const SizedBox(height: 18),
                  const Text(AppTheme.tagline, style: AppTheme.subtitle),
                  const SizedBox(height: 40),
                  _PrimaryPill(
                    label: 'New Account',
                    onPressed: () => _goToNewAccount(context),
                  ),
                  const SizedBox(height: 16),
                  _OutlinePill(
                    label: 'Sign In',
                    onPressed: () => _goToSignIn(context),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Filled pink call-to-action, sized to its content and left-aligned.
class _PrimaryPill extends StatelessWidget {
  const _PrimaryPill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.pillPink,
          foregroundColor: AppTheme.pillTextBlue,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 52, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}

/// Outlined secondary action, narrower than the primary pill.
class _OutlinePill extends StatelessWidget {
  const _OutlinePill({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
          side: const BorderSide(color: Colors.white70),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}

/// Two soft concentric arcs bleeding off the lower-right edge.
class _BackgroundCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withOpacity(0.06);

    final origin = Offset(size.width * 0.9, size.height * 0.72);
    for (final r in [size.width * 0.55, size.width * 0.8, size.width * 1.05]) {
      canvas.drawCircle(origin, r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}