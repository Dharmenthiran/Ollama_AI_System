import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors (ChatGPT-like dark theme)
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color sidebarBg = Color(0xFF171717);
  static const Color cardBg = Color(0xFF212121);
  static const Color accentColor = Color(0xFF10A37F); // OpenAI Green
  static const Color textMain = Color(0xFFECECF1);
  static const Color textDim = Color(0xFFB4B4B4);
  static const Color userBubble = Color(0xFF2F2F2F);
  static const Color aiBubble = Colors.transparent;

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accentColor,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: accentColor,
        secondary: accentColor,
        surface: cardBg,
        background: darkBg,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        bodyLarge: const TextStyle(color: textMain, fontSize: 16),
        bodyMedium: const TextStyle(color: textMain, fontSize: 14),
        titleMedium: const TextStyle(color: textMain, fontWeight: FontWeight.bold),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
      ),
      dividerColor: Colors.white10,
    );
  }
}
