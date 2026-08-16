import 'dart:ui';
import 'package:flutter/material.dart';

/// Central design-token class. Every colour, shadow, gradient and radius used
/// across the app must come from here so that switching themes is instant and
/// consistent.
///
/// Usage: `final t = AppTheme.of(context);`
class AppTheme {
  final BuildContext _context;
  AppTheme._(this._context);
  static AppTheme of(BuildContext context) => AppTheme._(context);

  bool get isDark => Theme.of(_context).brightness == Brightness.dark;

  // ────────────────────────────────────────────────────────────
  // BRAND PALETTE  (static – same in both modes)
  // ────────────────────────────────────────────────────────────
  static const Color primaryColor   = Color(0xFF6366F1); // Indigo 500
  static const Color primaryLight   = Color(0xFF818CF8); // Indigo 400
  static const Color primaryDark    = Color(0xFF4F46E5); // Indigo 600
  static const Color secondaryColor = Color(0xFFEC4899); // Pink 500
  static const Color accentColor    = Color(0xFF06B6D4); // Cyan 500
  static const Color successColor   = Color(0xFF10B981); // Emerald 500
  static const Color warningColor   = Color(0xFFF59E0B); // Amber 500
  static const Color errorColor     = Color(0xFFEF4444); // Red 500

  // ────────────────────────────────────────────────────────────
  // ADAPTIVE SURFACE COLOURS
  // ────────────────────────────────────────────────────────────
  Color get backgroundColor  => isDark ? const Color(0xFF0B0F1A) : const Color(0xFFF5F7FF);
  Color get surfaceColor     => isDark ? const Color(0xFF131829) : const Color(0xFFEEF1FB);
  Color get cardColor        => isDark ? const Color(0xFF1A2035) : Colors.white;
  Color get elevatedColor    => isDark ? const Color(0xFF212840) : const Color(0xFFF8FAFF);

  Color get textPrimaryColor   => isDark ? const Color(0xFFEDF0FF) : const Color(0xFF0D1240);
  Color get textSecondaryColor => isDark ? const Color(0xFF8891B0) : const Color(0xFF596490);
  Color get textTertiaryColor  => isDark ? const Color(0xFF4D5570) : const Color(0xFFB0B8D8);

  Color get dividerColor => isDark ? const Color(0xFF252D4A) : const Color(0xFFE0E6FF);

  // ────────────────────────────────────────────────────────────
  // GLASSMORPHISM
  // ────────────────────────────────────────────────────────────
  Color get glassColor => isDark
      ? const Color(0xFF1A2035).withOpacity(0.4)
      : Colors.white.withOpacity(0.5);

  LinearGradient get glassGradient => LinearGradient(
        colors: isDark
            ? [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02),
              ]
            : [
                Colors.white.withOpacity(0.7),
                Colors.white.withOpacity(0.3),
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  Color get glassBorderColor => isDark
      ? Colors.white.withOpacity(0.12)
      : Colors.white.withOpacity(0.6);

  double get glassBlur => 30.0;

  BoxDecoration glassDecoration({
    double borderRadius = radiusLarge,
    bool elevated = false,
  }) =>
      BoxDecoration(
        gradient: glassGradient,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: glassBorderColor, width: 1.0),
        boxShadow: elevated ? cardShadow : softShadow,
      );

  // ────────────────────────────────────────────────────────────
  // GRADIENTS
  // ────────────────────────────────────────────────────────────
  LinearGradient get primaryGradient => LinearGradient(
        colors: isDark
            ? [const Color(0xFF6366F1), const Color(0xFF9333EA)]
            : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get heroGradient => const LinearGradient(
        colors: [Color(0xFF4338CA), Color(0xFF7C3AED), Color(0xFFDB2777)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0.0, 0.55, 1.0],
      );

  LinearGradient get secondaryGradient => const LinearGradient(
        colors: [Color(0xFFEC4899), Color(0xFFF97316)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  LinearGradient get shimmerGradient => LinearGradient(
        colors: isDark
            ? [
                const Color(0xFF1A2035),
                const Color(0xFF252D4A),
                const Color(0xFF1A2035),
              ]
            : [
                const Color(0xFFEEF1FB),
                const Color(0xFFFFFFFF),
                const Color(0xFFEEF1FB),
              ],
        stops: const [0.0, 0.5, 1.0],
        begin: const Alignment(-1, 0),
        end: const Alignment(1, 0),
      );

  // ────────────────────────────────────────────────────────────
  // SHADOWS
  // ────────────────────────────────────────────────────────────
  /// Deep multi-layer card shadow
  List<BoxShadow> get cardShadow => isDark
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.40),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: primaryColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ]
      : [
          BoxShadow(
            color: primaryColor.withOpacity(0.10),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];

  /// Shallow soft shadow for inputs / chips
  List<BoxShadow> get softShadow => isDark
      ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ]
      : [
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 10,
            offset: const Offset(-4, -4),
          ),
          BoxShadow(
            color: const Color(0xFFB0B8D8).withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(4, 4),
          ),
        ];

  /// Coloured glow for CTAs / selected elements
  List<BoxShadow> get buttonShadow => [
        BoxShadow(
          color: primaryColor.withOpacity(isDark ? 0.5 : 0.35),
          blurRadius: 20,
          spreadRadius: -2,
          offset: const Offset(0, 6),
        ),
      ];

  List<BoxShadow> glowShadow(Color color, {double intensity = 0.5}) => [
        BoxShadow(
          color: color.withOpacity(intensity),
          blurRadius: 20,
          spreadRadius: -4,
          offset: const Offset(0, 4),
        ),
      ];

  // ────────────────────────────────────────────────────────────
  // BORDER RADIUS  (static constants – reuse these everywhere)
  // ────────────────────────────────────────────────────────────
  static const double radiusXSmall = 6.0;
  static const double radiusSmall  = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge  = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusFull   = 100.0;

  // ────────────────────────────────────────────────────────────
  // ANIMATION TOKENS
  // ────────────────────────────────────────────────────────────
  static const Duration fastAnimation   = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration slowAnimation   = Duration(milliseconds: 600);

  static const Curve springCurve = Curves.easeOutCubic;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve sharpCurve  = Curves.fastOutSlowIn;
  
  /// Standard delay for staggered lists (multiply by index)
  static const Duration staggerDelay = Duration(milliseconds: 100);
}

// ──────────────────────────────────────────────────────────────
// ANIMATION UTILITIES  (unchanged API so existing usage compiles)
// ──────────────────────────────────────────────────────────────
class AppAnimations {
  static Widget slideTransition({
    required Widget child,
    required AnimationController controller,
    Duration duration = AppTheme.mediumAnimation,
    Offset begin = const Offset(0, 0.3),
  }) {
    return SlideTransition(
      position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
        CurvedAnimation(parent: controller, curve: AppTheme.springCurve),
      ),
      child: child,
    );
  }

  static Widget fadeTransition({
    required Widget child,
    required AnimationController controller,
    Duration duration = AppTheme.mediumAnimation,
  }) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: controller, curve: AppTheme.springCurve),
      child: child,
    );
  }

  static Widget scaleTransition({
    required Widget child,
    required AnimationController controller,
    Duration duration = AppTheme.mediumAnimation,
  }) {
    return ScaleTransition(
      scale: CurvedAnimation(parent: controller, curve: AppTheme.bounceCurve),
      child: child,
    );
  }

  /// A custom [PageRouteBuilder] that slides in from the right + fades.
  static PageRouteBuilder<T> premiumRoute<T>({required Widget page}) {
    return PageRouteBuilder<T>(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: AppTheme.mediumAnimation,
      reverseTransitionDuration: AppTheme.fastAnimation,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end   = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: AppTheme.springCurve));
        final fade  = Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn));
        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(
            opacity: animation.drive(fade),
            child: child,
          ),
        );
      },
    );
  }
}
