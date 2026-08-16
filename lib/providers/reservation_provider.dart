import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reservation.dart';
import '../services/reservation_service.dart';

class ReservationProvider with ChangeNotifier {
  final ReservationService _reservationService = ReservationService();

  StreamSubscription<List<Reservation>>? _userSub;
  StreamSubscription<List<Reservation>>? _eventSub;

  List<Reservation> _userReservations = [];
  List<Reservation> _eventReservations = [];
  bool _isLoading = false;
  String? _error;

  List<Reservation> get userReservations => _userReservations;
  List<Reservation> get eventReservations => _eventReservations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /* ================= USER RESERVATIONS ================= */

  Future<void> loadUserReservations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _userSub?.cancel();
    _userSub = _reservationService
        .getReservationsByUser(userId)
        .listen(
          (reservations) {
            print('loadUserReservations($userId): Fetched ${reservations.length} reservations');
            _userReservations = reservations;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            print('loadUserReservations($userId): Error: $e');
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /* ================= EVENT RESERVATIONS ================= */

  Future<void> loadEventReservations(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await _eventSub?.cancel();
    _eventSub = _reservationService
        .getReservationsByEvent(eventId)
        .listen(
          (reservations) {
            _eventReservations = reservations;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  /* ================= CRUD ================= */

  Future<String> createReservation(Reservation reservation) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reservationId = await _reservationService.createReservation(
        reservation,
      );
      _isLoading = false;
      notifyListeners();
      return reservationId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> cancelReservation(String reservationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _reservationService.cancelReservation(reservationId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateReservationStatus(
    String reservationId,
    ReservationStatus status,
  ) async {
    try {
      await _reservationService.updateReservationStatus(reservationId, status);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /* ================= HELPERS ================= */

  Future<bool> hasReservationForEvent(String userId, String eventId) async {
    try {
      return await _reservationService.hasReservationForEvent(userId, eventId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<int> getTotalReservationsForEvent(String eventId) async {
    try {
      return await _reservationService.getTotalReservationsForEvent(eventId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return 0;
    }
  }

  Reservation? getReservationById(String reservationId) {
    try {
      return _userReservations.firstWhere(
        (r) => r.id == reservationId,
        orElse: () =>
            _eventReservations.firstWhere((r) => r.id == reservationId),
      );
    } catch (_) {
      return null;
    }
  }

  List<Reservation> getActiveReservations() {
    return _userReservations
        .where(
          (r) =>
              r.status == ReservationStatus.pending ||
              r.status == ReservationStatus.confirmed,
        )
        .toList();
  }

  List<Reservation> getPastReservations() {
    return _userReservations
        .where(
          (r) =>
              r.status == ReservationStatus.completed ||
              r.status == ReservationStatus.cancelled,
        )
        .toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /* ================= CLEANUP ================= */

  @override
  void dispose() {
    _userSub?.cancel();
    _eventSub?.cancel();
    super.dispose();
  }
}
