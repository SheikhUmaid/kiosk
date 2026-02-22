import 'package:flutter/material.dart';

/// Centralised blue-toned admin design tokens.
class AdminTheme {
  AdminTheme._();

  // ── Palette ──────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1565C0); // deep blue
  static const Color primaryLight = Color(0xFF1E88E5); // mid blue
  static const Color primaryXLight = Color(0xFFE3F0FF); // tint
  static const Color accent = Color(0xFF0288D1); // sky accent
  static const Color sidebar = Color(0xFF0D1B3E); // navy sidebar
  static const Color sidebarHover = Color(0xFF162550);
  static const Color sidebarActive = Color(0xFF1565C0);
  static const Color bg = Color(0xFFF4F7FB); // page bg
  static const Color surface = Colors.white;
  static const Color border = Color(0xFFDDE4EE);
  static const Color textPrimary = Color(0xFF0D1B3E);
  static const Color textSecondary = Color(0xFF6B7A99);
  static const Color textMuted = Color(0xFFAAB4C8);
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF57C00);
  static const Color danger = Color(0xFFC62828);

  // ── Card decoration ──────────────────────────────────────────────
  static BoxDecoration card({double radius = 14}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
    boxShadow: const [
      BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  // ── Section header style ─────────────────────────────────────────
  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.1,
  );

  static const TextStyle sectionSub = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
    letterSpacing: 0.3,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textMuted,
  );

  // ── Primary button ───────────────────────────────────────────────
  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primary,
    foregroundColor: Colors.white,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );

  // ── Outlined button ──────────────────────────────────────────────
  static ButtonStyle outlinedButton = OutlinedButton.styleFrom(
    foregroundColor: primary,
    side: const BorderSide(color: primary, width: 1.5),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
  );

  // ── Input decoration ─────────────────────────────────────────────
  static InputDecoration inputDecor(String label, {IconData? icon}) =>
      InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: textSecondary),
        prefixIcon: icon != null
            ? Icon(icon, size: 20, color: textSecondary)
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: danger),
        ),
      );
}
