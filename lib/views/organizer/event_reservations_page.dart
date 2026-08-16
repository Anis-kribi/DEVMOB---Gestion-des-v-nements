import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/reservation.dart';
import '../../models/user.dart';
import '../../providers/providers.dart';
import '../../services/services.dart';
import '../../utils/app_theme.dart';

class EventReservationsPage extends StatelessWidget {
  final Event event;

  const EventReservationsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      appBar: AppBar(
        title: Text('Réservations : ${event.title}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Reservation>>(
        stream: context.read<ReservationService>().getReservationsByEvent(event.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Erreur: \${snapshot.error}'));
          }

          final allReservations = snapshot.data ?? [];
          final reservations = allReservations.where((res) => res.status != ReservationStatus.cancelled).toList();

          if (reservations.isEmpty) {
            return const Center(
              child: Text('Aucune réservation pour cet événement.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              return FutureBuilder<User?>(
                future: context.read<AuthService>().getUserData(res.userId),
                builder: (context, userSnap) {
                  final user = userSnap.data;
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.person, color: theme.colorScheme.primary),
                      ),
                      title: Text(
                        userSnap.connectionState == ConnectionState.waiting
                            ? 'Chargement...'
                            : (user?.name ?? 'Utilisateur inconnu'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (user?.email != null)
                            Text(user!.email, style: TextStyle(color: appTheme.textSecondaryColor, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${res.numberOfTickets} ticket(s) • ${res.totalPrice.toStringAsFixed(0)} DT'),
                        ],
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(res.status).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStatusIcon(res.status), color: _getStatusColor(res.status), size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  _getStatusLabel(res.status),
                                  style: TextStyle(
                                    color: _getStatusColor(res.status),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (res.status == ReservationStatus.confirmed || res.status == ReservationStatus.pending) ...[
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.cancel, color: Colors.redAccent),
                              tooltip: 'Annuler la réservation',
                              onPressed: () => _confirmCancel(context, res),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.completed:
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  String _getStatusLabel(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed: return 'Confirmée';
      case ReservationStatus.cancelled: return 'Annulée';
      case ReservationStatus.completed: return 'Terminée';
      default: return 'En attente';
    }
  }

  IconData _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.confirmed:
        return Icons.check_circle;
      case ReservationStatus.cancelled:
        return Icons.cancel;
      case ReservationStatus.completed:
        return Icons.done_all;
      default:
        return Icons.hourglass_empty;
    }
  }

  void _confirmCancel(BuildContext context, Reservation res) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Êtes-vous sûr de vouloir annuler cette réservation pour cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Non'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ReservationProvider>().cancelReservation(res.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Oui, annuler', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
