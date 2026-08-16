import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createEvent(Event event) async {
    final doc = _firestore.collection('events').doc();
    await doc.set(event.copyWith(id: doc.id).toJson());
    return doc.id;
  }

  Stream<List<Event>> getEvents() => _firestore
      .collection('events')
      .snapshots()
      .map((s) {
        final events = <Event>[];
        for (final d in s.docs) {
          try {
            events.add(Event.fromJson(d.data()));
          } catch (e) {
            print('Error parsing event ${d.id}: $e');
          }
        }
        return events;
      });

  // Force refresh from server (bypass cache)
  Future<List<Event>> getAllEventsOnce() async {
    try {
      final snap = await _firestore.collection('events').get(
        const GetOptions(source: Source.serverAndCache),
      );
      final events = <Event>[];
      for (final d in snap.docs) {
        try {
          events.add(Event.fromJson(d.data()));
        } catch (e) {
          print('Error parsing event ${d.id}: $e');
        }
      }
      return events;
    } catch (e) {
      print('Error fetching events: $e');
      // Fallback to cache
      final snap = await _firestore.collection('events').get(
        const GetOptions(source: Source.cache),
      );
      final events = <Event>[];
      for (final d in snap.docs) {
        try {
          events.add(Event.fromJson(d.data()));
        } catch (e2) {
          print('Error parsing cached event ${d.id}: $e2');
        }
      }
      return events;
    }
  }

  Stream<List<Event>> getUpcomingEvents() => _firestore
      .collection('events')
      .where('startDate', isGreaterThan: Timestamp.now())
      .snapshots()
      .map((s) => s.docs.map((d) => Event.fromJson(d.data())).toList());

  Stream<List<Event>> getEventsByOrganizer(String uid) => _firestore
      .collection('events')
      .where('organizerId', isEqualTo: uid)
      .snapshots()
      .map((s) => s.docs.map((d) => Event.fromJson(d.data())).toList());

  Future<Event?> getEventById(String id) async {
    final doc = await _firestore.collection('events').doc(id).get();
    if (!doc.exists) return null;
    return Event.fromJson(doc.data()!);
  }

  Future<void> updateEvent(Event event) async =>
      _firestore.collection('events').doc(event.id).update(event.toJson());

  Future<void> deleteEvent(String id) async {
    // Cascading delete: delete all reservations for this event first
    final reservations = await _firestore
        .collection('reservations')
        .where('eventId', isEqualTo: id)
        .get();

    final batch = _firestore.batch();
    for (var doc in reservations.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Delete the event itself
    await _firestore.collection('events').doc(id).delete();
  }

  Future<void> updateAttendeeCount(String id, int count) async => _firestore
      .collection('events')
      .doc(id)
      .update({'currentAttendees': count});

  Future<List<Event>> searchEvents(String query) async {
    final snap = await _firestore.collection('events').get();
    return snap.docs
        .map((d) => Event.fromJson(d.data()))
        .where(
          (e) =>
              e.title.toLowerCase().contains(query.toLowerCase()) ||
              e.description.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }
}
