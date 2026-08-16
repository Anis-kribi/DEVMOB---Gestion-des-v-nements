import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_theme.dart';

/// Skeleton placeholder that matches [EventCard] proportions.
/// Shown in a [SliverList] while events are loading.
class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final baseColor = appTheme.surfaceColor;
    final highColor = appTheme.elevatedColor;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highColor,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category + price row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _shimmerBox(80, 22),
                _shimmerBox(60, 22),
              ],
            ),
            const SizedBox(height: 14),
            // Title
            _shimmerBox(double.infinity, 18),
            const SizedBox(height: 8),
            _shimmerBox(220, 18),
            const SizedBox(height: 12),
            // Description lines
            _shimmerBox(double.infinity, 13),
            const SizedBox(height: 6),
            _shimmerBox(260, 13),
            const SizedBox(height: 14),
            // Info row
            Row(
              children: [
                _shimmerBox(120, 13),
                const SizedBox(width: 16),
                _shimmerBox(80, 13),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox(double width, double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
      );
}
