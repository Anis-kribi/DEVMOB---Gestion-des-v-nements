import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';

/// A production-quality animated notification badge.
///
/// - Shows nothing when [count] is 0
/// - Animates the number change with a scale + fade bounce
/// - Caps display at 99+
/// - Never shows null / negative values
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  final double top;
  final double right;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.top = -4,
    this.right = -4,
  });

  @override
  Widget build(BuildContext context) {
    final safeCount = count.clamp(0, 999);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (safeCount > 0)
          Positioned(
            top: top,
            right: right,
            child: _BadgeLabel(count: safeCount),
          ),
      ],
    );
  }
}

class _BadgeLabel extends StatefulWidget {
  final int count;
  const _BadgeLabel({required this.count});

  @override
  State<_BadgeLabel> createState() => _BadgeLabelState();
}

class _BadgeLabelState extends State<_BadgeLabel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  int _displayedCount = 0;

  @override
  void initState() {
    super.initState();
    _displayedCount = widget.count;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.45)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: 1.45, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 50),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_BadgeLabel old) {
    super.didUpdateWidget(old);
    if (widget.count != old.count) {
      setState(() => _displayedCount = widget.count);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = _displayedCount > 99 ? '99+' : '$_displayedCount';

    return ScaleTransition(
      scale: _scale,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: Container(
          key: ValueKey(label),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppTheme.errorColor.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
