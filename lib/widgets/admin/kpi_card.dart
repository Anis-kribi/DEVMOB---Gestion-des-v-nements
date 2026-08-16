import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

/// An animated KPI (Key Performance Indicator) card.
///
/// Shows an icon, label, numeric value with an animated counter,
/// and a coloured glow accent — designed for the admin dashboard header.
class KpiCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color accentColor;
  final int animationDelay; // milliseconds
  final VoidCallback? onTap;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.animationDelay = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: appTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: accentColor.withOpacity(0.20),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(appTheme.isDark ? 0.18 : 0.10),
                blurRadius: 18,
                spreadRadius: -4,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(appTheme.isDark ? 0.30 : 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const SizedBox(height: 10),
              // Animated counter
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value.toDouble()),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (context, val, child) {
                  return Text(
                    val.toInt().toString(),
                    style: TextStyle(
                      color: appTheme.textPrimaryColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      letterSpacing: -0.5,
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: appTheme.textSecondaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: animationDelay))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
      ),
    );
  }
}
