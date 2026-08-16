import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/user.dart';
import '../../utils/app_theme.dart';

/// A premium, animated user list tile for the Admin Dashboard.
///
/// Shows a gradient-ring avatar keyed by role, a role chip,
/// and edit/delete action buttons with ripple effects.
class AdminUserTile extends StatelessWidget {
  final User user;
  final bool isCurrentUser;
  final int animationIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AdminUserTile({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.animationIndex,
    required this.onEdit,
    required this.onDelete,
  });

  static Color roleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFEF4444); // red
      case UserRole.organisateur:
        return const Color(0xFF6366F1); // indigo
      case UserRole.utilisateur:
        return const Color(0xFF10B981); // emerald
    }
  }

  static IconData roleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.shield_rounded;
      case UserRole.organisateur:
        return Icons.business_center_rounded;
      case UserRole.utilisateur:
        return Icons.person_rounded;
    }
  }

  static String roleLabel(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.organisateur:
        return 'Organisateur';
      case UserRole.utilisateur:
        return 'Utilisateur';
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final color = roleColor(user.role);
    final initials = user.name.isNotEmpty
        ? user.name.trim().split(' ').map((w) => w[0].toUpperCase()).take(2).join()
        : '?';

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
          onTap: isCurrentUser ? null : onEdit,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          splashColor: color.withOpacity(0.06),
          highlightColor: color.withOpacity(0.03),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // ── Gradient ring avatar ──
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.30),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Name + email + role chip ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                color: appTheme.textPrimaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser)
                            _chip(
                              label: 'Moi',
                              color: AppTheme.primaryColor,
                              icon: Icons.star_rounded,
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: appTheme.textSecondaryColor,
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      _chip(
                        label: roleLabel(user.role),
                        color: color,
                        icon: roleIcon(user.role),
                      ),
                    ],
                  ),
                ),

                // ── Actions ──
                if (!isCurrentUser)
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
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * animationIndex))
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOutCubic);
  }

  Widget _chip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}
