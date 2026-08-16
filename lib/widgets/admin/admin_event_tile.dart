import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../utils/app_theme.dart';

/// A premium event list tile for the Admin Dashboard.
///
/// Features a coloured left accent bar keyed by category,
/// an attendee capacity progress bar, and a date badge.
class AdminEventTile extends StatelessWidget {
  final Event event;
  final int animationIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminEventTile({
    super.key,
    required this.event,
    required this.animationIndex,
    required this.onEdit,
    required this.onDelete,
  });

  static Color _categoryColor(EventCategory cat) {
    switch (cat) {
      case EventCategory.music: return const Color(0xFF8B5CF6); // purple
      case EventCategory.sport: return const Color(0xFF10B981); // emerald
      case EventCategory.art: return const Color(0xFFEC4899); // pink
      case EventCategory.tech: return const Color(0xFF06B6D4); // cyan
      case EventCategory.food: return Colors.orange;
      case EventCategory.business: return Colors.blueGrey;
      case EventCategory.education: return Colors.indigo;
      case EventCategory.entertainment: return Colors.purpleAccent;
      case EventCategory.community: return Colors.teal;
      case EventCategory.health: return Colors.redAccent;
      case EventCategory.gaming: return Colors.deepPurple;
      case EventCategory.other: return Colors.grey;
    }
  }

  static IconData _categoryIcon(EventCategory cat) {
    switch (cat) {
      case EventCategory.music: return Icons.music_note_rounded;
      case EventCategory.sport: return Icons.sports_soccer_rounded;
      case EventCategory.art: return Icons.palette_rounded;
      case EventCategory.tech: return Icons.code_rounded;
      case EventCategory.food: return Icons.restaurant_rounded;
      case EventCategory.business: return Icons.business_center_rounded;
      case EventCategory.education: return Icons.school_rounded;
      case EventCategory.entertainment: return Icons.movie_rounded;
      case EventCategory.community: return Icons.people_rounded;
      case EventCategory.health: return Icons.favorite_rounded;
      case EventCategory.gaming: return Icons.sports_esports_rounded;
      case EventCategory.other: return Icons.category_rounded;
    }
  }

  static String _categoryLabel(EventCategory cat) {
    switch (cat) {
      case EventCategory.music: return 'Musique';
      case EventCategory.sport: return 'Sport';
      case EventCategory.art: return 'Art';
      case EventCategory.tech: return 'Tech';
      case EventCategory.food: return 'Gastronomie';
      case EventCategory.business: return 'Business';
      case EventCategory.education: return 'Éducation';
      case EventCategory.entertainment: return 'Divertissement';
      case EventCategory.community: return 'Communauté';
      case EventCategory.health: return 'Santé';
      case EventCategory.gaming: return 'Gaming';
      case EventCategory.other: return 'Autre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final color = _categoryColor(event.category);
    final fillRatio = event.maxAttendees > 0
        ? (event.currentAttendees / event.maxAttendees).clamp(0.0, 1.0)
        : 0.0;
    final isFull = fillRatio >= 1.0;
    final dateStr = DateFormat('dd MMM yyyy', 'fr_FR').format(event.startDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: appTheme.dividerColor, width: 1.0),
        boxShadow: appTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          splashColor: color.withOpacity(0.06),
          highlightColor: color.withOpacity(0.03),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // ── Left accent bar ──
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusLarge),
                      bottomLeft: Radius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                ),

                // ── Content ──
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row + actions
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category icon badge
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Icon(
                                _categoryIcon(event.category),
                                color: color,
                                size: 17,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: TextStyle(
                                      color: appTheme.textPrimaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today_rounded,
                                        size: 11,
                                        color: appTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        dateStr,
                                        style: TextStyle(
                                          color: appTheme.textSecondaryColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 11,
                                        color: appTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 2),
                                      Expanded(
                                        child: Text(
                                          event.location.address,
                                          style: TextStyle(
                                            color: appTheme.textSecondaryColor,
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Action buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _actionButton(
                                  icon: Icons.edit_rounded,
                                  color: AppTheme.primaryColor,
                                  tooltip: 'Modifier',
                                  onTap: onEdit,
                                ),
                                const SizedBox(width: 4),
                                _actionButton(
                                  icon: Icons.delete_outline_rounded,
                                  color: AppTheme.errorColor,
                                  tooltip: 'Supprimer',
                                  onTap: onDelete,
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // ── Capacity progress bar ──
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${event.currentAttendees} / ${event.maxAttendees} participants',
                                        style: TextStyle(
                                          color: appTheme.textSecondaryColor,
                                          fontSize: 11,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: isFull
                                              ? AppTheme.errorColor
                                                  .withOpacity(0.12)
                                              : color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusFull),
                                        ),
                                        child: Text(
                                          isFull
                                              ? 'Complet'
                                              : _categoryLabel(event.category),
                                          style: TextStyle(
                                            color: isFull
                                                ? AppTheme.errorColor
                                                : color,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull),
                                    child: LinearProgressIndicator(
                                      value: fillRatio,
                                      minHeight: 5,
                                      backgroundColor:
                                          appTheme.dividerColor,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        isFull ? AppTheme.errorColor : color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * animationIndex))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}
