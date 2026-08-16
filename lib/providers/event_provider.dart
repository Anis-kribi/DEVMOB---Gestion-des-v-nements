import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();

  StreamSubscription<List<Event>>? _eventsSub;
  StreamSubscription<List<Event>>? _upcomingSub;
  StreamSubscription<List<Event>>? _userEventsSub;

  List<Event> _events = [];
  List<Event> _upcomingEvents = [];
  List<Event> _userEvents = [];
  bool _isLoading = false;
  String? _error;

  List<Event> get events => _events;
  List<Event> get upcomingEvents => _upcomingEvents;
  List<Event> get userEvents => _userEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  EventProvider() {
    loadEvents();
    loadUpcomingEvents();
  }

  Future<void> loadEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventsSub?.cancel();
      _eventsSub = _eventService.getEvents().listen(
        (events) {
          _events = events;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
          // Fallback: try one-shot fetch
          _fallbackLoadEvents();
        },
      );

      // Timeout: if stream doesn't emit within 5 seconds, force a one-shot fetch
      Future.delayed(const Duration(seconds: 5), () {
        if (_isLoading && _events.isEmpty) {
          _fallbackLoadEvents();
        }
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fallback one-shot fetch when stream fails
  Future<void> _fallbackLoadEvents() async {
    try {
      final events = await _eventService.getAllEventsOnce();
      _events = events;
      _error = null;
    } catch (e) {
      _error = 'Impossible de charger les événements: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  // Manual refresh (called from UI)
  Future<void> refreshEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final events = await _eventService.getAllEventsOnce();
      _events = events;
      _error = null;
    } catch (e) {
      _error = 'Erreur de rafraîchissement: $e';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadUpcomingEvents() async {
    try {
      await _upcomingSub?.cancel();
      _upcomingSub = _eventService.getUpcomingEvents().listen(
        (events) {
          _upcomingEvents = events;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUserEvents(String userId) async {
    try {
      await _userEventsSub?.cancel();
      _userEventsSub = _eventService.getEventsByOrganizer(userId).listen((events) {
        _userEvents = events;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String> createEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final eventId = await _eventService.createEvent(event);
      _isLoading = false;
      notifyListeners();
      return eventId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.updateEvent(event);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.deleteEvent(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Event?> getEventById(String eventId) async {
    try {
      return await _eventService.getEventById(eventId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<Event>> searchEvents(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await _eventService.searchEvents(query);
      _isLoading = false;
      notifyListeners();
      return results;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAttendeeCount(String eventId, int newCount) async {
    try {
      await _eventService.updateAttendeeCount(eventId, newCount);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  List<Event> getEventsByCategory(EventCategory category) {
    return _events.where((event) => event.category == category).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> addEvent(Event newEvent) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.createEvent(newEvent);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    _upcomingSub?.cancel();
    _userEventsSub?.cancel();
    super.dispose();
  }
}
