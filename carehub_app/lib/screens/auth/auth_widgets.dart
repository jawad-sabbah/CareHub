import 'package:flutter/material.dart';

const authBgColor = Color(0xFF1E3FE0);
const authPillColor = Color(0xFFFCE4EC);
const authPillTextColor = Color(0xFF1E3FE0);

InputDecoration authFieldDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    prefixIcon: Icon(icon, color: Colors.white54),
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withOpacity(0.08),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide.none,
    ),
  );
}

Widget authLogo({IconData icon = Icons.add}) {
  return Center(
    child: Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.cyanAccent, width: 2),
      ),
      child: Icon(icon, color: Colors.cyanAccent, size: 36),
    ),
  );
}

/// Top-left arrow that returns to the welcome screen (the first route).
/// Top-left arrow that returns to the previous screen (the plan-choices page).
Widget authBackButton(BuildContext context) {
  return Align(
    alignment: Alignment.topLeft,
    child: IconButton(
      padding: EdgeInsets.zero,
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
}

/// Logo + optional brand line + title + subtitle, centered.
Widget authHeader({
  IconData icon = Icons.add,
  String? brand,
  required String title,
  required String subtitle,
  double titleSize = 24,
  double subtitleSize = 14,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      authLogo(icon: icon),
      const SizedBox(height: 16),
      if (brand != null) ...[
        Text(brand,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
      ],
      Text(title,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white, fontSize: titleSize, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text(subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: subtitleSize)),
    ],
  );
}

/// A white label sitting above its input [field].
Widget authLabeledField({required String label, required Widget field}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
      const SizedBox(height: 6),
      field,
    ],
  );
}

Widget authPrimaryButton({
  required String label,
  required bool isLoading,
  required VoidCallback? onPressed,
}) {
  return SizedBox(
    height: 52,
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: authPillColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: authPillTextColor),
            )
          : Text(label, style: const TextStyle(color: authPillTextColor, fontWeight: FontWeight.bold, fontSize: 15)),
    ),
  );
}

/// Outlined pill used for secondary actions (e.g. the "Sign In" footer).
Widget authSecondaryButton({
  required String label,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    height: 48,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        side: const BorderSide(color: Colors.white38),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}

void showAuthError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
  );
}