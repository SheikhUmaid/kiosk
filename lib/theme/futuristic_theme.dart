import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FuturisticTheme {
  // Colors
  static const Color bgDark = Color(0xFF0F0505); // Deepest Maroon/Black
  static const Color bgMaroon = Color(0xFF2E0505); // Dark Maroon
  static const Color primaryGold = Color(0xFFFFD700); // Neon Gold

  // Cyber Blue Palette
  static const Color bgBlueDark = Color(0xFF040B1A); // Deepest Blue
  static const Color bgBlueMid = Color(0xFF0A1931); // Navy Blue
  static const Color primaryBlue = Color(0xFF00D1FF); // Neon Blue
  static const Color accentBlue = Color(0xFF2979FF); // Bright Blue

  static const Color accentCyan = Color(0xFF00E5FF); // Cyber Cyan (Optional)
  static const Color surfaceGlass = Color(0x1FFFFFFF); // White 12%

  static const List<Color> bgGradient = [bgDark, bgMaroon, bgDark];

  static const List<Color> goldGradient = [
    Color(0xFFC4A35A),
    Color(0xFFFFD700),
    Color(0xFFC4A35A),
  ];

  // Text Styles
  static TextStyle get titleLarge => GoogleFonts.orbitron(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 2.0,
    shadows: [
      const Shadow(color: primaryGold, blurRadius: 10, offset: Offset(0, 0)),
    ],
  );

  static TextStyle get titleMedium => GoogleFonts.orbitron(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white.withOpacity(0.9),
    letterSpacing: 1.5,
  );

  static TextStyle get body => GoogleFonts.rajdhani(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: Colors.white.withOpacity(0.8),
    letterSpacing: 0.5,
  );

  static TextStyle get buttonText => GoogleFonts.orbitron(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryGold,
    letterSpacing: 1.2,
  );

  // Decorations
  static BoxDecoration glassBox = BoxDecoration(
    color: surfaceGlass,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  );

  static BoxDecoration frameDecoration(double progress) {
    return BoxDecoration(
      border: Border.all(
        color: primaryGold.withOpacity(0.5 + 0.5 * progress),
        width: 1 + progress,
      ),
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          primaryGold.withOpacity(0.1),
          Colors.transparent,
          primaryGold.withOpacity(0.1),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }
}

// Global Grid Painter
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    const double step = 50;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
