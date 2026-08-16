import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// A frosted-glass card with adaptive light/dark support.
///
/// Uses [BackdropFilter] + semi-transparent fill for a premium
/// glassmorphism look without being gaudy.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool elevated;
  final Gradient? gradient;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = AppTheme.radiusLarge,
    this.onTap,
    this.elevated = false,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final br       = BorderRadius.circular(borderRadius);

    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: appTheme.glassBlur,
          sigmaY: appTheme.glassBlur,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: br,
          child: InkWell(
            onTap: onTap,
            borderRadius: br,
            splashColor: AppTheme.primaryColor.withOpacity(0.06),
            highlightColor: AppTheme.primaryColor.withOpacity(0.03),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                gradient: gradient ?? appTheme.glassGradient,
                borderRadius: br,
                border: Border.all(
                  color: appTheme.glassBorderColor,
                  width: 1.5,
                ),
                boxShadow: elevated ? appTheme.cardShadow : appTheme.softShadow,
              ),
              child: Stack(
                children: [
                  // Inner bevel highlight
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: br,
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(appTheme.isDark ? 0.05 : 0.4),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(appTheme.isDark ? 0.2 : 0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: padding, // Apply padding inside the stack
                    child: child,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
