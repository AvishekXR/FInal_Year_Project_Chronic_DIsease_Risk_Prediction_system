import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

// Automatically picks the correct URL:
// → Web (Chrome/Edge) uses 127.0.0.1 (localhost)
// → Phone uses laptop's network IP
String get baseUrl {
  if (kIsWeb) {
    return "http://127.0.0.1:8000";
  } else {
    return "http://10.106.165.133:8000";
  }
}

// ─── Production Color Palette ────────────────────────────────────────────────
const Color primaryColor      = Color(0xFF00695C);  // Deep Teal   – health & brand
const Color primaryLight      = Color(0xFF26A69A);  // Light Teal  – accents
const Color primaryDark       = Color(0xFF004D40);  // Dark Teal   – gradient end
const Color secondaryColor    = Color(0xFF1565C0);  // Deep Blue   – trust & info
const Color lowRiskColor      = Color(0xFF2E7D32);  // Forest Green – low risk
const Color warningColor      = Color(0xFFE65100);  // Deep Orange – medium risk
const Color dangerColor       = Color(0xFFC62828);  // Deep Red    – high risk
const Color backgroundColor   = Color(0xFFF0F4F8);  // Cool off-white
const Color surfaceColor      = Colors.white;

// ─── Gradients ───────────────────────────────────────────────────────────────
const LinearGradient heroGradient = LinearGradient(
  colors: [Color(0xFF004D40), Color(0xFF00897B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient kidneyGradient = LinearGradient(
  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient diabetesGradient = LinearGradient(
  colors: [Color(0xFFBF360C), Color(0xFFFF7043)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient lowRiskGradient = LinearGradient(
  colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient mediumRiskGradient = LinearGradient(
  colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const LinearGradient highRiskGradient = LinearGradient(
  colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// ─── App Theme ───────────────────────────────────────────────────────────────
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    error: dangerColor,
    surface: backgroundColor,
  ),
  scaffoldBackgroundColor: backgroundColor,
  textTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      textStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: dangerColor),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
    helperStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Colors.white,
    margin: EdgeInsets.zero,
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? primaryColor
            : Colors.grey.shade400),
    trackColor: WidgetStateProperty.resolveWith((states) =>
        states.contains(WidgetState.selected)
            ? const Color(0xFF80CBC4)
            : Colors.grey.shade200),
  ),
);
