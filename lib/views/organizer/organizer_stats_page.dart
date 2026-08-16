import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../services/reservation_service.dart';
import '../../services/review_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_hero_background.dart';

class OrganizerStatsPage extends StatefulWidget {
  const OrganizerStatsPage({super.key});
  @override
  State<OrganizerStatsPage> createState() => _OrganizerStatsPageState();
}

class _OrganizerStatsPageState extends State<OrganizerStatsPage> {
  final _reservationService = ReservationService();
  final _reviewService = ReviewService();
  int _totalReservations = 0;
  double _averageFeedback = 0.0;
  int _upcomingEvents = 0;
  int _pastEvents = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    final eventProvider = context.read<EventProvider>();
    final authProvider = context.read<AuthProvider>();
    final myEvents = eventProvider.events
        .where((e) => e.organizerId == authProvider.user?.id)
        .toList();
    int totalRes = 0;
    double totalFeed = 0.0;
    int eventsWithFeedback = 0;
    int upcoming = 0;
    int past = 0;
    for (var event in myEvents) {
      if (event.endDate.isBefore(DateTime.now())) { past++; } else { upcoming++; }
      final resCount = await _reservationService.getTotalReservationsForEvent(event.id);
      totalRes += resCount;
      final avgRating = await _reviewService.getAverageRatingForEvent(event.id);
      if (avgRating > 0) { totalFeed += avgRating; eventsWithFeedback++; }
    }
    if (mounted) {
      setState(() {
        _totalReservations = totalRes;
        _averageFeedback = eventsWithFeedback > 0 ? (totalFeed / eventsWithFeedback) : 0.0;
        _upcomingEvents = upcoming;
        _pastEvents = past;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
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
              title: const Text('Statistiques',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
              background: PremiumHeroBackground(isDark: appTheme.isDark),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2.5)),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text('Vue d\'ensemble', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3))
                      .animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2, crossAxisSpacing: 14, mainAxisSpacing: 14,
                    shrinkWrap: true, childAspectRatio: 1.05,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _KpiCard(title: 'Total Inscrits', value: '$_totalReservations',
                          icon: Icons.people_alt_rounded, color: AppTheme.primaryColor,
                          gradient: appTheme.primaryGradient, index: 0),
                      _KpiCard(title: 'Feedback Moyen', value: '${_averageFeedback.toStringAsFixed(1)} / 5',
                          icon: Icons.star_rounded, color: AppTheme.warningColor,
                          gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          index: 1),
                      _KpiCard(title: 'À Venir', value: '$_upcomingEvents',
                          icon: Icons.event_available_rounded, color: AppTheme.successColor,
                          gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          index: 2),
                      _KpiCard(title: 'Passés', value: '$_pastEvents',
                          icon: Icons.history_rounded, color: AppTheme.accentColor,
                          gradient: const LinearGradient(colors: [Color(0xFF06B6D4), Color(0xFF0891B2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          index: 3),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('Performance', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.3))
                      .animate().fadeIn(delay: AppTheme.staggerDelay * 1, duration: AppTheme.mediumAnimation).slideX(begin: -0.1),
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    elevated: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ProgressRow(label: 'Événements à venir',
                            value: (_upcomingEvents + _pastEvents) == 0 ? 0.0 : _upcomingEvents / (_upcomingEvents + _pastEvents),
                            color: AppTheme.primaryColor, displayText: '$_upcomingEvents / ${_upcomingEvents + _pastEvents}', appTheme: appTheme, theme: theme),
                        const SizedBox(height: 20),
                        _ProgressRow(label: 'Satisfaction client',
                            value: _averageFeedback / 5.0,
                            color: AppTheme.warningColor, displayText: '${_averageFeedback.toStringAsFixed(1)} / 5', appTheme: appTheme, theme: theme),
                        const SizedBox(height: 20),
                        _ProgressRow(label: 'Réservations totales',
                            value: _totalReservations > 100 ? 1.0 : _totalReservations / 100,
                            color: AppTheme.successColor, displayText: '$_totalReservations', appTheme: appTheme, theme: theme),
                      ],
                    ),
                  ).animate().fadeIn(delay: AppTheme.staggerDelay * 2, duration: AppTheme.mediumAnimation).slideY(begin: 0.1),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final int index;
  const _KpiCard({required this.title, required this.value, required this.icon, required this.color, required this.gradient, required this.index});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, spreadRadius: -4, offset: const Offset(0, 8)),
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: appTheme.textPrimaryColor, letterSpacing: -0.5)),
          const SizedBox(height: 2),
          Text(title, style: TextStyle(fontSize: 12, color: appTheme.textSecondaryColor, fontWeight: FontWeight.w600)),
        ],
      ),
    ).animate(delay: AppTheme.staggerDelay * index).scale(begin: const Offset(0.85, 0.85), curve: AppTheme.springCurve).fadeIn();
  }
}

class _ProgressRow extends StatelessWidget {
  final String label, displayText;
  final double value;
  final Color color;
  final AppTheme appTheme;
  final ThemeData theme;
  const _ProgressRow({required this.label, required this.value, required this.color, required this.displayText, required this.appTheme, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: appTheme.textPrimaryColor)),
            Text(displayText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 7,
            backgroundColor: appTheme.dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
