import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_hero_background.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});
  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  String? _loadedUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = context.watch<AuthProvider>();
    final userId = authProvider.firebaseUser?.uid;
    if (userId != null && userId != _loadedUserId) {
      _loadedUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ReservationProvider>().loadUserReservations(userId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 170,
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
              titlePadding: const EdgeInsets.only(left: 20, bottom: 20),
              title: Consumer<ReservationProvider>(
                builder: (_, provider, __) {
                  final count = provider.userReservations
                      .where((r) => r.status != ReservationStatus.cancelled)
                      .length;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Mes Réservations',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5)),
                      if (count > 0)
                        Text('$count réservation${count > 1 ? "s" : ""} active${count > 1 ? "s" : ""}',
                            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  );
                },
              ),
              background: PremiumHeroBackground(isDark: appTheme.isDark),
            ),
          ),

          // ── Body ───────────────────────────────────────────────
          Consumer<ReservationProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.userReservations.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2.5)),
                );
              }
              if (provider.error != null) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.error_outline_rounded, size: 52, color: AppTheme.errorColor.withOpacity(0.7)),
                        const SizedBox(height: 16),
                        Text('Une erreur est survenue', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        Text(provider.error!, style: TextStyle(color: appTheme.textSecondaryColor), textAlign: TextAlign.center),
                      ]),
                    ),
                  ),
                );
              }

              final reservations = provider.userReservations
                  .where((r) => r.status != ReservationStatus.cancelled)
                  .toList();

              if (reservations.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.08), shape: BoxShape.circle),
                        child: const Icon(Icons.bookmark_border_rounded, size: 52, color: AppTheme.primaryColor),
                      ).animate(onPlay: (c) => c.repeat(reverse: true))
                          .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 2000.ms, curve: Curves.easeInOut),
                      const SizedBox(height: 20),
                      Text('Aucune réservation', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700))
                          .animate().fadeIn().slideY(begin: 0.2),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text('Explorez les événements pour en réserver',
                            style: TextStyle(color: appTheme.textSecondaryColor), textAlign: TextAlign.center),
                      ).animate(delay: 100.ms).fadeIn(),
                    ]),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reservation = reservations[index];
                      final statusColor = _statusColor(reservation.status);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: GlassCard(
                          padding: EdgeInsets.zero,
                          borderRadius: AppTheme.radiusLarge,
                          elevated: false,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Status accent bar
                                  Container(width: 4, color: statusColor),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(children: [
                                            Container(
                                              width: 44, height: 44,
                                              decoration: BoxDecoration(gradient: appTheme.primaryGradient,
                                                  borderRadius: BorderRadius.circular(12)),
                                              child: const Icon(Icons.event_rounded, color: Colors.white, size: 22),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                Builder(builder: (ctx) {
                                                  final event = ctx.read<EventProvider>().events.cast<Event?>()
                                                      .firstWhere((e) => e?.id == reservation.eventId, orElse: () => null);
                                                  return Text(event?.title ?? 'Événement Inconnu',
                                                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                                      maxLines: 1, overflow: TextOverflow.ellipsis);
                                                }),
                                                const SizedBox(height: 2),
                                                Text(dateFormat.format(reservation.createdAt),
                                                    style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor)),
                                              ]),
                                            ),
                                            _StatusBadge(status: reservation.status),
                                          ]),
                                          const SizedBox(height: 14),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                                color: appTheme.surfaceColor,
                                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
                                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                              _DetailStat(
                                                icon: Icons.confirmation_number_rounded,
                                                label: 'Billets',
                                                value: '${reservation.numberOfTickets}',
                                                appTheme: appTheme, theme: theme,
                                              ),
                                              Container(width: 1, height: 32, color: appTheme.dividerColor),
                                              _DetailStat(
                                                icon: Icons.payments_rounded,
                                                label: 'Total',
                                                value: reservation.totalPrice > 0
                                                    ? '${reservation.totalPrice.toStringAsFixed(0)} DT'
                                                    : 'Gratuit',
                                                valueColor: reservation.totalPrice > 0 ? AppTheme.primaryColor : AppTheme.successColor,
                                                appTheme: appTheme, theme: theme,
                                              ),
                                            ]),
                                          ),
                                          if (reservation.status == ReservationStatus.confirmed) ...[
                                            const SizedBox(height: 12),
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton.icon(
                                                onPressed: () => provider.cancelReservation(reservation.id),
                                                icon: const Icon(Icons.close_rounded, size: 16),
                                                label: const Text('Annuler la réservation'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppTheme.errorColor,
                                                  side: BorderSide(color: AppTheme.errorColor.withOpacity(0.7)),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate(delay: AppTheme.staggerDelay * index).fadeIn(duration: AppTheme.mediumAnimation).slideY(begin: 0.2, curve: AppTheme.springCurve);
                    },
                    childCount: reservations.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed: return AppTheme.successColor;
      case ReservationStatus.pending: return AppTheme.warningColor;
      case ReservationStatus.cancelled: return AppTheme.errorColor;
      case ReservationStatus.completed: return AppTheme.primaryColor;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final ReservationStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case ReservationStatus.confirmed: color = AppTheme.successColor; label = 'Confirmé'; break;
      case ReservationStatus.pending: color = AppTheme.warningColor; label = 'En attente'; break;
      case ReservationStatus.cancelled: color = AppTheme.errorColor; label = 'Annulé'; break;
      case ReservationStatus.completed: color = AppTheme.primaryColor; label = 'Terminé'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color? valueColor;
  final AppTheme appTheme;
  final ThemeData theme;
  const _DetailStat({required this.icon, required this.label, required this.value,
      this.valueColor, required this.appTheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Icon(icon, size: 18, color: AppTheme.primaryColor),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: valueColor ?? appTheme.textPrimaryColor)),
      Text(label, style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor)),
    ]);
  }
}
