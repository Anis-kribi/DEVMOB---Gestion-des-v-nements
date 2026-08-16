import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/app_theme.dart';

/// Gradient hero background with animated decorative orbs.
/// Use this inside the flexibleSpace of a SliverAppBar.
class PremiumHeroBackground extends StatelessWidget {
  final bool isDark;
  const PremiumHeroBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.of(context).heroGradient),
      child: Stack(
        children: [
          const Positioned(top: -50, right: -50, child: _Orb(size: 160, opacity: 0.12)),
          const Positioned(bottom: -30, left: -30, child: _Orb(size: 110, opacity: 0.08)),
          const Positioned(top: 30, right: 80, child: _Orb(size: 60, opacity: 0.06)),
          const Positioned(top: 60, left: 40, child: _Orb(size: 80, opacity: 0.05)),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size;
  final double opacity;
  const _Orb({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(begin: const Offset(1, 1), end: const Offset(1.16, 1.16),
            duration: 3200.ms, curve: Curves.easeInOut)
        .moveY(begin: 0, end: 8, duration: 3200.ms, curve: Curves.easeInOut);
  }
}
