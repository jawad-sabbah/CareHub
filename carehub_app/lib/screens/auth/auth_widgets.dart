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

void showAuthError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: Colors.red.shade400),
  );
}