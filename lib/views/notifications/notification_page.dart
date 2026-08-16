import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../../providers/providers.dart';
import '../../providers/reservation_provider.dart';
import '../../services/services.dart';
import '../../models/models.dart';
import '../../utils/app_theme.dart';
import '../../widgets/glass_card.dart';

class NotificationPage extends StatefulWidget {
  final List<String> eventIds;
  const NotificationPage({super.key, required this.eventIds});
  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Set<String> _clearedIds = {};
  bool _clearAll = false;
  final Set<String> _processing = {};
  late Stream<List<QueryDocumentSnapshot>> _notificationsStream;
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  void _initStream() {
    _notificationsStream = _createCombinedStream();
  }

  @override
  void didUpdateWidget(NotificationPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.eventIds != oldWidget.eventIds) _initStream();
  }

  Future<void> _updateStatus(BuildContext context, String reservationId, ReservationStatus status) async {
    setState(() => _processing.add(reservationId));
    try {
      await context.read<ReservationProvider>().updateReservationStatus(reservationId, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            Icon(status == ReservationStatus.confirmed ? Icons.check_circle_rounded : Icons.cancel_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text(status == ReservationStatus.confirmed ? 'Réservation acceptée' : 'Réservation refusée'),
          ]),
          backgroundColor: status == ReservationStatus.confirmed ? AppTheme.successColor : AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _processing.remove(reservationId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: appTheme.heroGradient),
        ),
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
            child: IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white, size: 22),
              tooltip: 'Effacer tout',
              onPressed: () async {
                final resSnap = await FirebaseFirestore.instance.collection('reservations')
                    .where('eventId', whereIn: widget.eventIds.take(10).toList()).get();
                for (var doc in resSnap.docs) { doc.reference.update({'notificationCleared': true}); }
                final revSnap = await FirebaseFirestore.instance.collection('reviews')
                    .where('eventId', whereIn: widget.eventIds.take(10).toList()).get();
                for (var doc in revSnap.docs) { doc.reference.update({'notificationCleared': true}); }
                setState(() { _clearAll = true; });
              },
            ),
          ),
        ],
      ),
      body: widget.eventIds.isEmpty
          ? _buildEmptyState(appTheme, theme, 'Aucun événement créé', 'Créez un événement pour voir les notifications ici.')
          : StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: _notificationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor, strokeWidth: 2.5));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}', style: TextStyle(color: AppTheme.errorColor)));
                }
                final docs = snapshot.data ?? [];
                final sortedDocs = List.of(docs);
                sortedDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  DateTime toTime(dynamic val) {
                    if (val is Timestamp) return val.toDate();
                    if (val is String) return DateTime.tryParse(val) ?? DateTime.fromMillisecondsSinceEpoch(0);
                    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
                    return DateTime.fromMillisecondsSinceEpoch(0);
                  }
                  return toTime(bData['createdAt']).compareTo(toTime(aData['createdAt']));
                });

                final currentUserId = context.read<AuthProvider>().user?.id;
                final visibleDocs = _clearAll ? [] : sortedDocs.where((doc) {
                  if (_clearedIds.contains(doc.id)) return false;
                  final data = doc.data() as Map<String, dynamic>;
                  if (data['notificationCleared'] == true) return false;
                  final isReservation = doc.reference.parent.id == 'reservations';
                  if (!isReservation && data['userId'] == currentUserId) return false;
                  if (isReservation && data['status'] == 2) return false;
                  return true;
                }).toList();

                if (visibleDocs.isEmpty) {
                  return _buildEmptyState(appTheme, theme, 'Aucune notification', 'Tout est à jour pour le moment.');
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  itemCount: visibleDocs.length,
                  itemBuilder: (context, index) {
                    final doc = visibleDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final isReservation = doc.reference.parent.id == 'reservations';
                    return FutureBuilder<Map<String, dynamic>>(
                      future: _fetchGenericDetails(context, data, isReservation),
                      builder: (context, detailsSnap) {
                        final userData = detailsSnap.data?['user'];
                        final userName = userData?.name ?? 'Utilisateur #${(data['userId'] as String).substring(0, 8)}';
                        final userEmail = userData?.email ?? '';
                        final eventTitle = detailsSnap.data?['event']?.title ?? 'Événement #${(data['eventId'] as String).substring(0, 8)}';

                        if (!isReservation) {
                          final review = Review.fromJson({...data, 'id': doc.id});
                          return _buildReviewCard(context, review, userName, userEmail, eventTitle, appTheme, theme);
                        }

                        final res = Reservation.fromJson({...data, 'id': doc.id});
                        final isProcessing = _processing.contains(res.id);
                        final isPending = res.status == ReservationStatus.pending;

                        return _buildReservationCard(context, res, userName, userEmail, eventTitle, isProcessing, isPending, appTheme, theme);
                      },
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(AppTheme appTheme, ThemeData theme, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppTheme.primaryColor.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, size: 52, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 20),
          Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(subtitle, style: TextStyle(color: appTheme.textSecondaryColor), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(BuildContext context, Reservation res, String userName, String userEmail,
      String eventTitle, bool isProcessing, bool isPending, AppTheme appTheme, ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppTheme.radiusLarge,
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(gradient: appTheme.primaryGradient, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: const Icon(Icons.confirmation_number_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  if (userEmail.isNotEmpty)
                    Text(userEmail, style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor)),
                ]),
              ),
              _statusBadge(res.status),
              const SizedBox(width: 4),
              _dismissButton(() {
                FirebaseFirestore.instance.collection('reservations').doc(res.id).update({'notificationCleared': true});
                setState(() => _clearedIds.add(res.id));
              }, appTheme),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: appTheme.surfaceColor, borderRadius: BorderRadius.circular(AppTheme.radiusSmall)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.event_rounded, size: 13, color: AppTheme.primaryColor),
                  const SizedBox(width: 6),
                  Expanded(child: Text(eventTitle, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.confirmation_number_rounded, size: 13, color: appTheme.textSecondaryColor),
                  const SizedBox(width: 6),
                  Text('${res.numberOfTickets} billet(s)', style: TextStyle(fontSize: 12, color: appTheme.textSecondaryColor)),
                  const Spacer(),
                  Icon(Icons.schedule_rounded, size: 12, color: appTheme.textTertiaryColor),
                  const SizedBox(width: 4),
                  Text(_dateFormat.format(res.createdAt), style: TextStyle(fontSize: 11, color: appTheme.textTertiaryColor)),
                ]),
              ],
            ),
          ),
          if (isPending) ...[
            const SizedBox(height: 14),
            if (isProcessing)
              const Center(child: SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor)))
            else
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(context, res.id, ReservationStatus.cancelled),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(context, res.id, ReservationStatus.confirmed),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Accepter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
                      ),
                    ),
                  ),
                ),
              ]),
          ],
        ],
      ),
    ).animate().fadeIn(duration: AppTheme.mediumAnimation).slideY(begin: 0.2, curve: AppTheme.springCurve);
  }

  Widget _buildReviewCard(BuildContext context, Review review, String userName, String userEmail,
      String eventTitle, AppTheme appTheme, ThemeData theme) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppTheme.radiusLarge,
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: const Icon(Icons.star_rounded, color: AppTheme.warningColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              if (userEmail.isNotEmpty)
                Text(userEmail, style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: AppTheme.warningColor.withOpacity(0.12), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(review.rating.toStringAsFixed(1), style: const TextStyle(color: AppTheme.warningColor, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(width: 3),
                const Icon(Icons.star_rounded, size: 11, color: AppTheme.warningColor),
              ]),
            ),
            const SizedBox(width: 4),
            _dismissButton(() {
              FirebaseFirestore.instance.collection('reviews').doc(review.id).update({'notificationCleared': true});
              setState(() => _clearedIds.add(review.id));
            }, appTheme),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            Icon(Icons.event_rounded, size: 13, color: AppTheme.primaryColor),
            const SizedBox(width: 6),
            Expanded(child: Text(eventTitle, style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w600, fontSize: 13))),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: appTheme.surfaceColor, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
            child: Text(review.comment ?? 'Aucun commentaire.',
                style: TextStyle(fontSize: 13, height: 1.5, color: appTheme.textPrimaryColor,
                    fontStyle: review.comment == null ? FontStyle.italic : FontStyle.normal)),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(_dateFormat.format(review.createdAt), style: TextStyle(fontSize: 10, color: appTheme.textTertiaryColor)),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppTheme.mediumAnimation).slideY(begin: 0.2, curve: AppTheme.springCurve);
  }

  Widget _statusBadge(ReservationStatus status) {
    Color color;
    String label;
    switch (status) {
      case ReservationStatus.pending: color = AppTheme.warningColor; label = 'En attente'; break;
      case ReservationStatus.confirmed: color = AppTheme.successColor; label = 'Acceptée'; break;
      case ReservationStatus.cancelled: color = AppTheme.errorColor; label = 'Refusée'; break;
      case ReservationStatus.completed: color = AppTheme.accentColor; label = 'Terminée'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(AppTheme.radiusFull)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }

  Widget _dismissButton(VoidCallback onTap, AppTheme appTheme) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(Icons.close_rounded, size: 18, color: appTheme.textSecondaryColor),
      ),
    );
  }

  Stream<List<QueryDocumentSnapshot>> _createCombinedStream() {
    final controller = StreamController<List<QueryDocumentSnapshot>>();
    final resStream = FirebaseFirestore.instance.collection('reservations')
        .where('eventId', whereIn: widget.eventIds.take(10).toList()).snapshots();
    final revStream = FirebaseFirestore.instance.collection('reviews')
        .where('eventId', whereIn: widget.eventIds.take(10).toList()).snapshots();
    List<QueryDocumentSnapshot> reservations = [];
    List<QueryDocumentSnapshot> reviews = [];
    StreamSubscription? sub1, sub2;
    sub1 = resStream.listen((snapshot) {
      reservations = snapshot.docs;
      if (!controller.isClosed) controller.add([...reservations, ...reviews]);
    });
    sub2 = revStream.listen((snapshot) {
      reviews = snapshot.docs;
      if (!controller.isClosed) controller.add([...reservations, ...reviews]);
    });
    controller.onCancel = () { sub1?.cancel(); sub2?.cancel(); };
    return controller.stream;
  }

  Future<Map<String, dynamic>> _fetchGenericDetails(BuildContext context, Map<String, dynamic> data, bool isReservation) async {
    final eventService = context.read<EventService>();
    final authService = context.read<AuthService>();
    final user = await authService.getUserData(data['userId'] as String);
    final event = await eventService.getEventById(data['eventId'] as String);
    return {'user': user, 'event': event};
  }
}
