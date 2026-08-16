import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import '../../providers/reservation_provider.dart';
import '../../models/models.dart';
import '../../services/services.dart';
import '../../utils/app_theme.dart';

/// Premium Notification page for the Admin panel.
/// Tab 1 — Pending reservations (Accept / Refuse)
/// Tab 2 — Newly created events by organizers
class AdminNotificationPage extends StatefulWidget {
  const AdminNotificationPage({super.key});

  @override
  State<AdminNotificationPage> createState() => _AdminNotificationPageState();
}

class _AdminNotificationPageState extends State<AdminNotificationPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DateFormat _fmt = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerScrolled) => [
          SliverAppBar(
            automaticallyImplyLeading: false,
            pinned: true,
            floating: false,
            expandedHeight: 140,
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2D1B69),
                      AppTheme.primaryDark,
                      const Color(0xFF1A1040),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -50,
                      right: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryColor.withOpacity(0.12),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding:
                            const EdgeInsets.fromLTRB(20, 12, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Notifications',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.only(left: 52),
                              child: Text(
                                'Réservations et événements récents',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.60),
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              indicatorWeight: 2.5,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(
                      Icons.confirmation_number_rounded, size: 18),
                  text: 'Réservations',
                  height: 52,
                ),
                Tab(
                  icon: Icon(Icons.event_note_rounded, size: 18),
                  text: 'Événements',
                  height: 52,
                ),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _ReservationsTab(fmt: _fmt),
            _EventsTab(fmt: _fmt),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// TAB 1 — Pending Reservations
// ══════════════════════════════════════════════════════════

class _ReservationsTab extends StatefulWidget {
  final DateFormat fmt;
  const _ReservationsTab({required this.fmt});

  @override
  State<_ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<_ReservationsTab> {
  final Set<String> _processing = {};

  Future<void> _updateStatus(
      BuildContext context, String id, ReservationStatus status) async {
    setState(() => _processing.add(id));
    try {
      await context
          .read<ReservationProvider>()
          .updateReservationStatus(id, status);
      if (mounted) {
        _toast(
          context,
          status == ReservationStatus.confirmed
              ? 'Réservation acceptée'
              : 'Réservation refusée',
          success: status == ReservationStatus.confirmed,
        );
      }
    } catch (e) {
      if (mounted) _toast(context, 'Erreur: $e', success: false);
    } finally {
      if (mounted) setState(() => _processing.remove(id));
    }
  }

  void _toast(BuildContext context, String msg, {required bool success}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [
          Icon(
            success
                ? Icons.check_circle_rounded
                : Icons.error_outline_rounded,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(msg)),
        ]),
        backgroundColor: success ? AppTheme.successColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reservations')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeleton(appTheme);
        }
        if (snapshot.hasError) {
          return _errorView(snapshot.error.toString(), appTheme);
        }

        final docs = snapshot.data?.docs ?? [];
        final pending = <Reservation>[];
        for (var doc in docs) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id;
            final res = Reservation.fromJson(data);
            if (res.status == ReservationStatus.pending) pending.add(res);
          } catch (_) {}
        }

        if (pending.isEmpty) {
          return _emptyState(
            icon: Icons.check_circle_outline_rounded,
            label: 'Aucune réservation en attente',
            appTheme: appTheme,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pending.length,
          itemBuilder: (context, i) {
            final res = pending[i];
            return _PremiumReservationCard(
              reservation: res,
              fmt: widget.fmt,
              appTheme: appTheme,
              isProcessing: _processing.contains(res.id),
              animationIndex: i,
              onAccept: () =>
                  _updateStatus(context, res.id, ReservationStatus.confirmed),
              onRefuse: () =>
                  _updateStatus(context, res.id, ReservationStatus.cancelled),
            );
          },
        );
      },
    );
  }

  Widget _skeleton(AppTheme appTheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) => Container(
        height: 130,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1200.ms,
            color: appTheme.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
          ),
    );
  }

  Widget _errorView(String error, AppTheme appTheme) {
    return Center(
      child: Text('Erreur: $error',
          style: const TextStyle(color: AppTheme.errorColor)),
    );
  }

  Widget _emptyState(
      {required IconData icon,
      required String label,
      required AppTheme appTheme}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.successColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child:
                Icon(icon, size: 40, color: AppTheme.successColor),
          ),
          const SizedBox(height: 16),
          Text(label,
              style: TextStyle(
                  color: appTheme.textSecondaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

// ── Premium Reservation Card ─────────────────────────────────────────

class _PremiumReservationCard extends StatelessWidget {
  final Reservation reservation;
  final DateFormat fmt;
  final AppTheme appTheme;
  final bool isProcessing;
  final int animationIndex;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  const _PremiumReservationCard({
    required this.reservation,
    required this.fmt,
    required this.appTheme,
    required this.isProcessing,
    required this.animationIndex,
    required this.onAccept,
    required this.onRefuse,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchDetails(context),
      builder: (context, snap) {
        final userName = snap.data?['userName'] as String? ??
            'Utilisateur #${reservation.userId.length > 5 ? reservation.userId.substring(0, 6) : reservation.userId}';
        final userEmail = snap.data?['userEmail'] as String? ?? '';
        final eventTitle = snap.data?['eventTitle'] as String? ??
            'Événement #${reservation.eventId.length > 5 ? reservation.eventId.substring(0, 6) : reservation.eventId}';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: appTheme.cardColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.warningColor.withOpacity(0.25),
              width: 1.0,
            ),
            boxShadow: appTheme.cardShadow,
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Orange accent bar
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppTheme.radiusLarge),
                      bottomLeft: Radius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: user + pending badge
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.warningColor,
                                    AppTheme.warningColor.withOpacity(0.6)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                  size: 19),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    userName,
                                    style: TextStyle(
                                        color: appTheme.textPrimaryColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (userEmail.isNotEmpty)
                                    Text(
                                      userEmail,
                                      style: TextStyle(
                                          color: appTheme.textSecondaryColor,
                                          fontSize: 11),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusFull),
                              ),
                              child: Text('En attente',
                                  style: TextStyle(
                                      color: AppTheme.warningColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Event info
                        _infoRow(Icons.event_rounded, eventTitle,
                            color: AppTheme.primaryColor),
                        _infoRow(
                            Icons.confirmation_number_rounded,
                            '${reservation.numberOfTickets} ticket(s)'),
                        _infoRow(Icons.schedule_rounded,
                            fmt.format(reservation.createdAt)),

                        const SizedBox(height: 12),

                        // Action buttons
                        if (isProcessing)
                          const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.warningColor),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: OutlinedButton.icon(
                                    onPressed: onRefuse,
                                    icon: const Icon(Icons.close_rounded,
                                        size: 16),
                                    label: const FittedBox(child: Text('Refuser')),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.errorColor,
                                      side: BorderSide(
                                          color: AppTheme.errorColor
                                              .withOpacity(0.5)),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusMedium)),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 40,
                                  child: ElevatedButton.icon(
                                    onPressed: onAccept,
                                    icon: const Icon(Icons.check_rounded,
                                        size: 16),
                                    label: const FittedBox(child: Text('Accepter')),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successColor,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 0, horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppTheme.radiusMedium)),
                                    ),
                                  ),
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
        )
            .animate(delay: Duration(milliseconds: 60 * animationIndex))
            .fadeIn(duration: 350.ms)
            .slideY(begin: 0.1, end: 0, duration: 350.ms,
                curve: Curves.easeOutCubic);
      },
    );
  }

  Widget _infoRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon,
              size: 13,
              color: color ?? appTheme.textSecondaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: color ?? appTheme.textSecondaryColor,
                fontWeight:
                    color != null ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _fetchDetails(BuildContext context) async {
    final authService = context.read<AuthService>();
    final eventService = context.read<EventService>();
    try {
      final user = await authService.getUserData(reservation.userId);
      final event = await eventService.getEventById(reservation.eventId);
      return {
        'userName': user?.name,
        'userEmail': user?.email,
        'eventTitle': event?.title,
      };
    } catch (_) {
      return {};
    }
  }
}

// ══════════════════════════════════════════════════════════
// TAB 2 — Events by Organizers
// ══════════════════════════════════════════════════════════

class _EventsTab extends StatelessWidget {
  final DateFormat fmt;
  const _EventsTab({required this.fmt});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('events')
          .orderBy('createdAt', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _skeleton(appTheme);
        }
        if (snapshot.hasError) {
          return Center(
              child: Text('Erreur: ${snapshot.error}',
                  style: const TextStyle(color: AppTheme.errorColor)));
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.event_busy_rounded,
                      size: 40,
                      color: AppTheme.accentColor.withOpacity(0.5)),
                ),
                const SizedBox(height: 16),
                Text('Aucun événement récent',
                    style: TextStyle(
                        color: appTheme.textSecondaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
              ],
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.9, 0.9)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final data = docs[i].data() as Map<String, dynamic>;
            data['id'] = docs[i].id;
            return _PremiumEventNotifCard(
              data: data,
              fmt: fmt,
              appTheme: appTheme,
              animationIndex: i,
            );
          },
        );
      },
    );
  }

  Widget _skeleton(AppTheme appTheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (_, i) => Container(
        height: 120,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1200.ms,
            color: appTheme.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
          ),
    );
  }
}

class _PremiumEventNotifCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final DateFormat fmt;
  final AppTheme appTheme;
  final int animationIndex;

  const _PremiumEventNotifCard({
    required this.data,
    required this.fmt,
    required this.appTheme,
    required this.animationIndex,
  });

  static const _cats = ['Musique', 'Sport', 'Art', 'Tech'];
  static const _catColors = [
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
  ];
  static const _catIcons = [
    Icons.music_note_rounded,
    Icons.sports_soccer_rounded,
    Icons.palette_rounded,
    Icons.code_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Sans titre';
    final organizerId = data['organizerId']?.toString() ?? '';
    final maxAttendees = (data['maxAttendees'] as num?)?.toInt() ?? 0;
    final location =
        (data['location'] as Map<String, dynamic>?)?['address']?.toString() ??
            '';

    DateTime? createdAt;
    if (data['createdAt'] is Timestamp) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else if (data['createdAt'] != null) {
      createdAt = DateTime.tryParse(data['createdAt'].toString());
    }

    int catIdx = 0;
    if (data['category'] is int) {
      catIdx = (data['category'] as int).clamp(0, 3);
    }
    final catColor = _catColors[catIdx];
    final catIcon = _catIcons[catIdx];
    final catLabel = _cats[catIdx];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: catColor.withOpacity(0.20),
          width: 1.0,
        ),
        boxShadow: appTheme.cardShadow,
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Category accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: catColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLarge),
                  bottomLeft: Radius.circular(AppTheme.radiusLarge),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Icon(catIcon, color: catColor, size: 19),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: appTheme.textPrimaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: catColor.withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(catLabel,
                              style: TextStyle(
                                  color: catColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (location.isNotEmpty)
                      _row(Icons.location_on_rounded, location),
                    _row(Icons.people_outline_rounded,
                        '$maxAttendees participants max'),
                    if (createdAt != null)
                      _row(Icons.schedule_rounded, fmt.format(createdAt)),
                    if (organizerId.isNotEmpty)
                      FutureBuilder(
                        future: context
                            .read<AuthService>()
                            .getUserData(organizerId),
                        builder: (context, snap) {
                          final name = snap.data?.name ?? 'Organisateur';
                          return _row(Icons.business_rounded, 'Par $name');
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * animationIndex))
        .fadeIn(duration: 350.ms)
        .slideY(
            begin: 0.1,
            end: 0,
            duration: 350.ms,
            curve: Curves.easeOutCubic);
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: appTheme.textSecondaryColor),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: appTheme.textSecondaryColor),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
