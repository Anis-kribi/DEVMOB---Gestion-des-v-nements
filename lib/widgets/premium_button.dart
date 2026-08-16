import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

/// A premium gradient button with:
/// - Scale-down press effect (micro-interaction)
/// - Coloured glow shadow
/// - Optional loading spinner
/// - Full ripple contained inside rounded corners
class PremiumButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;
  final double height;
  final Gradient? gradient;
  final Color? solidColor;
  final BorderRadius? borderRadius;

  const PremiumButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.width,
    this.height = 56,
    this.gradient,
    this.solidColor,
    this.borderRadius,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null && !widget.isLoading) _ctrl.forward();
  }

  void _onTapUp(_) => _ctrl.reverse();
  void _onTapCancel()  => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final br = widget.borderRadius ??
        BorderRadius.circular(AppTheme.radiusMedium);
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final gradient   = widget.gradient ?? appTheme.primaryGradient;

    return GestureDetector(
      onTapDown:   _onTapDown,
      onTapUp:     _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isDisabled ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: isDisabled ? 1.0 : _scale.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: AppTheme.fastAnimation,
          width:  widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: isDisabled ? null : gradient,
            color:    isDisabled
                ? appTheme.surfaceColor
                : widget.solidColor,
            borderRadius: br,
            boxShadow: isDisabled ? [] : appTheme.buttonShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              borderRadius: br,
              splashColor: Colors.white.withOpacity(0.15),
              highlightColor: Colors.white.withOpacity(0.08),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: isDisabled
                                  ? appTheme.textSecondaryColor
                                  : Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                              color: isDisabled
                                  ? appTheme.textSecondaryColor
                                  : Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
