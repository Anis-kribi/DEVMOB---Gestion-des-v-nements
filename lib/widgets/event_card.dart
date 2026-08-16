import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../utils/app_theme.dart';
import '../utils/app_theme.dart' as devmob_theme;
import 'glass_card.dart';
import '../services/review_service.dart' as devmob_reviews;

class EventCard extends StatefulWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewReservations;
  final bool showActions;
  /// Position in the list — used to stagger the entrance animation.
  final int animationIndex;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onViewReservations,
    this.showActions = false,
    this.animationIndex = 0,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 160),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.975).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final appTheme = AppTheme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');
    final catColor   = _getCategoryColor(widget.event.category);

    // Staggered entrance: each card delays by staggerDelay × its index
    final delay = AppTheme.staggerDelay * widget.animationIndex;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (_, child) => Transform.scale(
          scale: _pressScale.value,
          child: child,
        ),
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onTap != null) _pressCtrl.forward();
          },
          onTapUp:     (_) => _pressCtrl.reverse(),
          onTapCancel: ()  => _pressCtrl.reverse(),
          onTap: widget.onTap,
          child: GlassCard(
            elevated: true,
            borderRadius: AppTheme.radiusLarge,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Coloured header strip ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        catColor.withOpacity(appTheme.isDark ? 0.20 : 0.10),
                        Colors.transparent,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(AppTheme.radiusLarge),
                      topRight: Radius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Category pill
                      _CategoryPill(
                        icon:  _getCategoryIcon(widget.event.category),
                        label: _getCategoryName(widget.event.category),
                        color: catColor,
                      ),
                      const Spacer(),
                      // Price pill
                      _PricePill(
                        price: widget.event.price,
                        appTheme: appTheme,
                      ),
                    ],
                  ),
                ),

                // ─── Body ────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              widget.event.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildAvailabilityBadge(widget.event.availabilityStatus, appTheme),
                        ],
                      ),

                      if (widget.event.description.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          widget.event.description,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 12),

                      // Info chips row
                      Wrap(
                        spacing: 14,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.calendar_today_rounded,
                            label: dateFormat.format(widget.event.startDate),
                            appTheme: appTheme,
                          ),
                          if (widget.event.location.address.isNotEmpty)
                            _InfoChip(
                              icon: Icons.location_on_rounded,
                              label: widget.event.location.address,
                              appTheme: appTheme,
                            ),
                          _InfoChip(
                            icon: Icons.people_rounded,
                            label:
                                '${widget.event.currentAttendees}/${widget.event.maxAttendees}',
                            appTheme: appTheme,
                          ),
                          // Rating Chip
                          FutureBuilder<double>(
                            future: devmob_reviews.ReviewService().getAverageRatingForEvent(widget.event.id),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || snapshot.data == 0) {
                                return const SizedBox.shrink();
                              }
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: devmob_theme.AppTheme.warningColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    snapshot.data!.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: appTheme.textPrimaryColor,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ─── Organizer action bar ─────────────────────────────────
                if (widget.showActions)
                  _ActionBar(
                    onViewReservations: widget.onViewReservations,
                    onEdit:   widget.onEdit,
                    onDelete: widget.onDelete,
                    appTheme: appTheme,
                    theme:    theme,
                  ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 400.ms, curve: Curves.easeOut)
        .slideY(begin: 0.25, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  // ── helpers ───────────────────────────────────────────────────────
  Color _getCategoryColor(EventCategory c) {
    switch (c) {
      case EventCategory.music:  return AppTheme.primaryColor;
      case EventCategory.sport:  return AppTheme.successColor;
      case EventCategory.art:    return AppTheme.warningColor;
      case EventCategory.tech:   return AppTheme.accentColor;
      case EventCategory.food:   return Colors.orange;
      case EventCategory.business: return Colors.blueGrey;
      case EventCategory.education: return Colors.indigo;
      case EventCategory.entertainment: return Colors.purpleAccent;
      case EventCategory.community: return Colors.teal;
      case EventCategory.health: return Colors.redAccent;
      case EventCategory.gaming: return Colors.deepPurple;
      case EventCategory.other:  return Colors.grey;
    }
  }

  IconData _getCategoryIcon(EventCategory c) {
    switch (c) {
      case EventCategory.music:  return Icons.music_note_rounded;
      case EventCategory.sport:  return Icons.sports_soccer_rounded;
      case EventCategory.art:    return Icons.brush_rounded;
      case EventCategory.tech:   return Icons.computer_rounded;
      case EventCategory.food:   return Icons.restaurant_rounded;
      case EventCategory.business: return Icons.business_center_rounded;
      case EventCategory.education: return Icons.school_rounded;
      case EventCategory.entertainment: return Icons.movie_rounded;
      case EventCategory.community: return Icons.people_rounded;
      case EventCategory.health: return Icons.favorite_rounded;
      case EventCategory.gaming: return Icons.sports_esports_rounded;
      case EventCategory.other:  return Icons.category_rounded;
    }
  }

  String _getCategoryName(EventCategory c) {
    switch (c) {
      case EventCategory.music:  return 'Musique';
      case EventCategory.sport:  return 'Sport';
      case EventCategory.art:    return 'Art';
      case EventCategory.tech:   return 'Technologie';
      case EventCategory.food:   return 'Gastronomie';
      case EventCategory.business: return 'Business';
      case EventCategory.education: return 'Éducation';
      case EventCategory.entertainment: return 'Divertissement';
      case EventCategory.community: return 'Communauté';
      case EventCategory.health: return 'Santé';
      case EventCategory.gaming: return 'Gaming';
      case EventCategory.other:  return 'Autre';
    }
  }

  Widget _buildAvailabilityBadge(String status, AppTheme appTheme) {
    Color color;
    if (status == 'Complet') color = AppTheme.errorColor;
    else if (status == 'En attente') color = AppTheme.warningColor;
    else color = AppTheme.successColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _CategoryPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _CategoryPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final double? price;
  final AppTheme appTheme;

  const _PricePill({required this.price, required this.appTheme});

  @override
  Widget build(BuildContext context) {
    final isFree  = (price ?? 0) <= 0;
    final color   = isFree ? AppTheme.accentColor : AppTheme.successColor;
    final label   = isFree ? 'Gratuit' : '${price!.toStringAsFixed(0)} DT';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppTheme appTheme;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.appTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: appTheme.textTertiaryColor),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: appTheme.textSecondaryColor,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  final VoidCallback? onViewReservations;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final AppTheme appTheme;
  final ThemeData theme;

  const _ActionBar({
    this.onViewReservations,
    this.onEdit,
    this.onDelete,
    required this.appTheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: appTheme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (onViewReservations != null)
            _buildActionBtn(
              icon: Icons.people_rounded,
              label: 'Réservations',
              color: AppTheme.accentColor,
              onTap: onViewReservations,
            ),
          _buildActionBtn(
            icon: Icons.edit_rounded,
            label: 'Modifier',
            color: theme.colorScheme.primary,
            onTap: onEdit,
          ),
          _buildActionBtn(
            icon: Icons.delete_rounded,
            label: 'Supprimer',
            color: AppTheme.errorColor,
            onTap: onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
