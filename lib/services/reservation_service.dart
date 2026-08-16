import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reservation.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a reservation with transaction (checks capacity and updates event)
  Future<String> createReservation(Reservation reservation) async {
    // First check for an existing active reservation (outside transaction)
    final existingCheck = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: reservation.userId)
        .where('eventId', isEqualTo: reservation.eventId)
        .get();

    // Filter client-side for active statuses (pending=0, confirmed=1)
    // Check removed to allow creating multiple reservations


    final eventRef = _firestore.collection('events').doc(reservation.eventId);
    final reservationRef = _firestore.collection('reservations').doc();

    return _firestore.runTransaction((transaction) async {
      final eventSnapshot = await transaction.get(eventRef);

      if (!eventSnapshot.exists) {
        throw Exception('L\'événement n\'existe plus.');
      }

      final maxAttendees = eventSnapshot.get('maxAttendees') as int;
      final currentAttendees = eventSnapshot.get('currentAttendees') as int;

      if (currentAttendees >= maxAttendees) {
        throw Exception('Désolé, cet événement est complet.');
      }

      // Create reservation
      transaction.set(
        reservationRef,
        reservation.copyWith(id: reservationRef.id).toJson(),
      );

      // Increment attendee count
      transaction.update(eventRef, {
        'currentAttendees': FieldValue.increment(1),
      });

      return reservationRef.id;
    });
  }

  // Get reservations by user
  Stream<List<Reservation>> getReservationsByUser(String userId) {
    return _firestore
        .collection('reservations')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Reservation.fromJson(data);
          }).toList();
          // Sort client-side to avoid requiring a composite index in Firestore
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Get reservations by event
  Stream<List<Reservation>> getReservationsByEvent(String eventId) {
    return _firestore
        .collection('reservations')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Reservation.fromJson(data);
          }).toList();
        });
  }

  // Get reservation by ID
  Future<Reservation?> getReservationById(String reservationId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('reservations')
          .doc(reservationId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Reservation.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la réservation: $e');
    }
  }

  // Update reservation status
  Future<void> updateReservationStatus(
    String reservationId,
    ReservationStatus status,
  ) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': status.index,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Cancel reservation
  Future<void> cancelReservation(String reservationId) async {
    await updateReservationStatus(reservationId, ReservationStatus.cancelled);
  }

  // Check if user has reservation for event
  Future<bool> hasReservationForEvent(String userId, String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reservations')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where(
            'status',
            whereIn: [
              ReservationStatus.pending.index,
              ReservationStatus.confirmed.index,
            ],
          )
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking reservation: $e');
      return false;
    }
  }

  // Get total reservations count for event
  Future<int> getTotalReservationsForEvent(String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reservations')
          .where('eventId', isEqualTo: eventId)
          .where(
            'status',
            whereIn: [
              ReservationStatus.pending.index,
              ReservationStatus.confirmed.index,
            ],
          )
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting reservation count: $e');
      return 0;
    }
  }
}
