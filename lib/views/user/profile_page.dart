import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_hero_background.dart';
import 'edit_profile_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ─── Premium Header ───────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryColor,
            surfaceTintColor: Colors.transparent,
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
            ),
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PremiumHeroBackground(isDark: appTheme.isDark),
                  SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        // Avatar with gradient ring
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: appTheme.primaryGradient,
                          ),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: Icon(Icons.person_rounded, size: 42, color: Colors.white.withOpacity(0.9)),
                          ),
                        )
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(begin: const Offset(1, 1), end: const Offset(1.04, 1.04), duration: 3000.ms, curve: Curves.easeInOut),
                        const SizedBox(height: 12),
                        Text(
                          user?.name ?? 'Utilisateur',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                        ).animate().fadeIn(delay: AppTheme.staggerDelay).slideY(begin: -0.1),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                          ),
                          child: Text(
                            user?.role == UserRole.organisateur ? '🎯  Organisateur' : '👤  Utilisateur',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ).animate().fadeIn(delay: AppTheme.staggerDelay * 2).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Content ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // ── Account info ──
                  _SectionLabel(label: 'Informations', theme: theme),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: AppTheme.radiusLarge,
                    elevated: false,
                    child: Column(children: [
                      _InfoTile(
                        icon: Icons.email_rounded,
                        iconColor: AppTheme.primaryColor,
                        label: 'Email',
                        value: user?.email ?? '-',
                        appTheme: appTheme,
                        theme: theme,
                      ),
                      Divider(color: appTheme.dividerColor, height: 1, indent: 60),
                      _InfoTile(
                        icon: Icons.badge_rounded,
                        iconColor: AppTheme.accentColor,
                        label: 'Rôle',
                        value: user?.role == UserRole.organisateur ? 'Organisateur' : 'Utilisateur',
                        appTheme: appTheme,
                        theme: theme,
                      ),
                    ]),
                  ).animate().fadeIn(delay: AppTheme.staggerDelay * 1, duration: AppTheme.mediumAnimation).slideY(begin: 0.2, curve: AppTheme.springCurve),

                  const SizedBox(height: 24),

                  // ── Preferences ──
                  _SectionLabel(label: 'Préférences', theme: theme),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: AppTheme.radiusLarge,
                    elevated: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Icon(themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              color: AppTheme.primaryColor, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Mode sombre', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                          Text(themeProvider.isDarkMode ? 'Activé' : 'Désactivé',
                              style: TextStyle(fontSize: 12, color: appTheme.textSecondaryColor)),
                        ])),
                        Switch.adaptive(
                          value: themeProvider.isDarkMode,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          activeColor: AppTheme.primaryColor,
                        ),
                      ]),
                    ),
                  ).animate().fadeIn(delay: AppTheme.staggerDelay * 2, duration: AppTheme.mediumAnimation).slideY(begin: 0.2, curve: AppTheme.springCurve),

                  const SizedBox(height: 24),

                  // ── Actions ──
                  _SectionLabel(label: 'Actions', theme: theme),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    borderRadius: AppTheme.radiusLarge,
                    elevated: false,
                    child: Column(children: [
                      _ActionTile(
                        icon: Icons.edit_rounded,
                        iconColor: AppTheme.primaryColor,
                        label: 'Éditer le profil',
                        subtitle: 'Modifier informations et mot de passe',
                        appTheme: appTheme,
                        theme: theme,
                        onTap: () => showDialog(context: context, builder: (ctx) => const EditProfileDialog()),
                      ),
                      Divider(color: appTheme.dividerColor, height: 1, indent: 60),
                      if (user?.role == UserRole.organisateur) ...[
                        _ActionTile(
                          icon: Icons.swap_horiz_rounded,
                          iconColor: AppTheme.accentColor,
                          label: 'Changer de rôle',
                          subtitle: 'Basculer entre utilisateur et organisateur',
                          appTheme: appTheme,
                          theme: theme,
                          onTap: () => _showRoleDialog(context),
                        ),
                        Divider(color: appTheme.dividerColor, height: 1, indent: 60),
                      ],
                      _ActionTile(
                        icon: Icons.logout_rounded,
                        iconColor: AppTheme.errorColor,
                        label: 'Se déconnecter',
                        subtitle: 'Déconnexion de votre compte',
                        appTheme: appTheme,
                        theme: theme,
                        showArrow: false,
                        onTap: () async { await authProvider.signOut(); },
                      ),
                    ]),
                  ).animate().fadeIn(delay: AppTheme.staggerDelay * 3, duration: AppTheme.mediumAnimation).slideY(begin: 0.2, curve: AppTheme.springCurve),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final authProvider = context.read<AuthProvider>();
    final currentRole = authProvider.user?.role ?? UserRole.utilisateur;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: appTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXLarge)),
        title: const Text('Changer de rôle', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          'Vous êtes actuellement ${currentRole == UserRole.organisateur ? "organisateur" : "utilisateur"}.\n\n'
          'Passer en mode ${currentRole == UserRole.organisateur ? "utilisateur" : "organisateur"} ?',
          style: TextStyle(color: appTheme.textSecondaryColor, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler', style: TextStyle(color: appTheme.textSecondaryColor, fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            onPressed: () {
              final newRole = currentRole == UserRole.organisateur ? UserRole.utilisateur : UserRole.organisateur;
              authProvider.updateRole(newRole);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
            ),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeData theme;
  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.2)),
    );
  }
}

// ─── Info tile ────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;
  final AppTheme appTheme;
  final ThemeData theme;
  const _InfoTile({required this.icon, required this.iconColor, required this.label, required this.value, required this.appTheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor, fontWeight: FontWeight.w500)),
          const SizedBox(height: 1),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
        ]),
      ]),
    );
  }
}

// ─── Action tile ──────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, subtitle;
  final AppTheme appTheme;
  final ThemeData theme;
  final VoidCallback onTap;
  final bool showArrow;
  const _ActionTile({required this.icon, required this.iconColor, required this.label, required this.subtitle,
      required this.appTheme, required this.theme, required this.onTap, this.showArrow = true});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, fontSize: 14)),
            Text(subtitle, style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor)),
          ])),
          if (showArrow) Icon(Icons.chevron_right_rounded, color: appTheme.textTertiaryColor),
        ]),
      ),
    );
  }
}
