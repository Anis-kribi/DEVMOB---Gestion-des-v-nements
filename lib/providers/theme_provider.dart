import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isDarkMode = false;

  ThemeMode get themeMode  => _themeMode;
  bool       get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_themeKey) == 'dark') {
      _themeMode = ThemeMode.dark;
      _isDarkMode = true;
    } else {
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      _isDarkMode = true;
      await prefs.setString(_themeKey, 'dark');
    } else {
      _themeMode = ThemeMode.light;
      _isDarkMode = false;
      await prefs.setString(_themeKey, 'light');
    }
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ══════════════════════════════════════════════════════════════
  ThemeData get lightTheme {
    const primary    = AppTheme.primaryColor;
    const primaryL   = AppTheme.primaryLight;
    const secondary  = AppTheme.secondaryColor;
    final baseText   = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
        primary: primary,
        secondary: secondary,
        tertiary: AppTheme.accentColor,
        surface: const Color(0xFFF5F7FF),
        error: AppTheme.errorColor,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FF),
      textTheme: _buildTextTheme(baseText, Brightness.light),

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
          letterSpacing: -0.4,
        ),
      ),

      // ── Cards ───────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
      ),

      // ── ElevatedButton ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ── FilledButton (M3) ────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),

      // ── OutlinedButton ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
      ),

      // ── Inputs ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFEEF1FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFDDE2F5), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(color: const Color(0xFFB0B8D8), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF596490), fontSize: 14, fontWeight: FontWeight.w500),
      ),

      // ── FAB ─────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: StadiumBorder(),
      ),

      // ── NavigationBar (M3) ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: primary.withOpacity(0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF8891B0), size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = GoogleFonts.inter(fontSize: 11);
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(fontWeight: FontWeight.w700, color: primary);
          }
          return base.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF8891B0));
        }),
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.08),
        height: 72,
      ),

      // ── Chips ───────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEEF1FB),
        selectedColor: primaryL,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        side: const BorderSide(color: Color(0xFFDDE2F5), width: 1),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Dialogs ─────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
        elevation: 12,
      ),

      // ── SnackBar ────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF0D1240),
        contentTextStyle: GoogleFonts.inter(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E6FF),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  DARK THEME
  // ══════════════════════════════════════════════════════════════
  ThemeData get darkTheme {
    const primary    = AppTheme.primaryLight; // slightly lighter for dark bg
    const secondary  = AppTheme.secondaryColor;
    final baseText   = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppTheme.primaryColor,
        brightness: Brightness.dark,
        primary: primary,
        secondary: secondary,
        tertiary: AppTheme.accentColor,
        surface: const Color(0xFF131829),
        error: AppTheme.errorColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF0B0F1A),
      textTheme: _buildTextTheme(baseText, Brightness.dark),

      // ── AppBar ──────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFEDF0FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFEDF0FF),
          letterSpacing: -0.4,
        ),
      ),

      // ── Cards ───────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: const Color(0xFF1A2035),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
      ),

      // ── ElevatedButton ──────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
        ),
      ),

      // ── FilledButton ────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),

      // ── OutlinedButton ──────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
      ),

      // ── Inputs ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF131829),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: Color(0xFF252D4A), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          borderSide: const BorderSide(color: AppTheme.errorColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(color: const Color(0xFF4D5570), fontSize: 14),
        labelStyle: GoogleFonts.inter(color: const Color(0xFF8891B0), fontSize: 14, fontWeight: FontWeight.w500),
      ),

      // ── FAB ─────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: const StadiumBorder(),
      ),

      // ── NavigationBar (M3) ──────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF131829),
        indicatorColor: AppTheme.primaryColor.withOpacity(0.20),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: Color(0xFF4D5570), size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = GoogleFonts.inter(fontSize: 11);
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(fontWeight: FontWeight.w700, color: primary);
          }
          return base.copyWith(fontWeight: FontWeight.w500, color: const Color(0xFF4D5570));
        }),
        elevation: 0,
        height: 72,
      ),

      // ── Chips ───────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF131829),
        selectedColor: AppTheme.primaryColor,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
        side: const BorderSide(color: Color(0xFF252D4A), width: 1),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      // ── Dialogs ─────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1A2035),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
        elevation: 12,
      ),

      // ── SnackBar ────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF212840),
        contentTextStyle: GoogleFonts.inter(color: const Color(0xFFEDF0FF), fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFF252D4A),
        thickness: 1,
        space: 1,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  //  TEXT THEME  (Inter – shared builder for both modes)
  // ══════════════════════════════════════════════════════════════
  TextTheme _buildTextTheme(TextTheme base, Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final primary   = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0D1240);
    final secondary = dark ? const Color(0xFF8891B0) : const Color(0xFF596490);
    final tertiary  = dark ? const Color(0xFF4D5570) : const Color(0xFFB0B8D8);

    return GoogleFonts.interTextTheme(base).copyWith(
      displayLarge:  _ts(36, FontWeight.w900, primary,   -0.5, 1.15),
      displayMedium: _ts(30, FontWeight.w800, primary,   -0.4, 1.15),
      displaySmall:  _ts(24, FontWeight.w800, primary,   -0.3, 1.2),
      headlineLarge: _ts(22, FontWeight.w700, primary,   -0.3, 1.3),
      headlineMedium:_ts(20, FontWeight.w700, primary,   -0.2, 1.3),
      headlineSmall: _ts(18, FontWeight.w600, primary,   -0.2, 1.3),
      titleLarge:    _ts(16, FontWeight.w700, primary,   -0.1, 1.4),
      titleMedium:   _ts(14, FontWeight.w600, primary,    0.0, 1.4),
      titleSmall:    _ts(13, FontWeight.w600, secondary,  0.0, 1.4),
      bodyLarge:     _ts(16, FontWeight.w400, primary,    0.0, 1.6),
      bodyMedium:    _ts(14, FontWeight.w400, secondary,  0.0, 1.6),
      bodySmall:     _ts(12, FontWeight.w400, tertiary,   0.0, 1.5),
      labelLarge:    _ts(14, FontWeight.w600, primary,    0.1, 1.3),
      labelMedium:   _ts(12, FontWeight.w600, secondary,  0.1, 1.3),
      labelSmall:    _ts(11, FontWeight.w500, tertiary,   0.2, 1.3),
    );
  }

  TextStyle _ts(double size, FontWeight weight, Color color,
      double spacing, double height) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: spacing,
        height: height,
      );
}
