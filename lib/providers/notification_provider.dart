import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Single source of truth for admin notification counts.
///
/// Listens to a Firestore stream of pending reservations and
/// exposes a live [pendingCount]. The count is always derived
/// directly from the snapshot size — never accumulated — which
/// guarantees accuracy even after accepts/refusals.
class NotificationProvider with ChangeNotifier {
  // ── Internal state ──────────────────────────────────────────────────
  int _pendingCount = 0;
  int _reviewCount = 0;
  bool _isLoading = true;
  String? _error;
  
  // To notify the UI of a freshly added reservation or review
  Map<String, dynamic>? freshlyAddedReservation;
  Map<String, dynamic>? freshlyAddedReview;

  StreamSubscription<QuerySnapshot>? _sub;
  StreamSubscription<QuerySnapshot>? _reviewSub;

  // ── Public API ───────────────────────────────────────────────────────
  int get pendingCount => (_pendingCount + _reviewCount).clamp(0, 999);
  bool get hasNotifications => _pendingCount > 0;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// If [eventIds] is provided, filters reservations to only those events (max 10).
  /// If [organizerId] is provided, notifications for reviews made by this user are ignored.
  void startListening({List<String>? eventIds, String? organizerId}) {
    _sub?.cancel();
    _reviewSub?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (eventIds != null && eventIds.isEmpty) {
      // Organizer has no events, so no reservations
      _pendingCount = 0;
      _reviewCount = 0;
      _isLoading = false;
      notifyListeners();
      return;
    }

    Query query = FirebaseFirestore.instance
        .collection('reservations')
        .where('status', isEqualTo: 0); // ReservationStatus.pending.index

    if (eventIds != null) {
      query = query.where('eventId', whereIn: eventIds.take(10).toList());
    }

    _sub = query.snapshots().listen(
      (snapshot) {
        // Detect newly added reservations
        if (_pendingCount != 0 || snapshot.docs.isNotEmpty) {
           for (var change in snapshot.docChanges) {
             if (change.type == DocumentChangeType.added) {
               // Only trigger for genuinely new ones (not initial load usually)
               // Firestore initial load fires 'added' too, but often from local cache if metadata.isFromCache is true
               if (!snapshot.metadata.isFromCache) {
                  freshlyAddedReservation = {"eventId": change.doc['eventId'], "id": change.doc.id};
               }
             }
           }
        }
        
        _pendingCount = snapshot.docs.length;
        _isLoading = false;
        _error = null;
        notifyListeners();
        
        // Reset the fresh notification so it doesn't trigger multiple times
        if (freshlyAddedReservation != null) {
          Future.delayed(Duration.zero, () {
            freshlyAddedReservation = null;
          });
        }
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );

    // --- Listen to Reviews ---
    if (eventIds != null && eventIds.isNotEmpty) {
      _reviewSub = FirebaseFirestore.instance
          .collection('reviews')
          .where('eventId', whereIn: eventIds.take(10).toList())
          .where('notificationCleared', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        // Filter out reviews made by the organizer themselves
        final filteredDocs = snapshot.docs.where((doc) {
          if (organizerId == null) return true;
          final data = doc.data();
          return data['userId'] != organizerId;
        }).toList();

        _reviewCount = filteredDocs.length;
        if (!snapshot.metadata.isFromCache) {
          for (var change in snapshot.docChanges) {
            if (change.type == DocumentChangeType.added) {
              final data = change.doc.data() as Map<String, dynamic>;
              if (organizerId != null && data['userId'] == organizerId) {
                continue;
              }

              freshlyAddedReview = {
                "eventId": data['eventId'],
                "id": change.doc.id,
                "comment": data['comment']
              };
              
              // Reset after a frame
              Future.delayed(Duration.zero, () {
                freshlyAddedReview = null;
              });
            }
          }
        }
        notifyListeners();
      });
    }
  }


  /// Stops the stream (call from dispose / log-out).
  void stopListening() {
    _sub?.cancel();
    _sub = null;
    _reviewSub?.cancel();
    _reviewSub = null;
    _pendingCount = 0;
    _reviewCount = 0;
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _reviewSub?.cancel();
    super.dispose();
  }
}
