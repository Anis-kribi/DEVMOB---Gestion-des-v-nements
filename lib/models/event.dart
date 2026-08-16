import 'package:cloud_firestore/cloud_firestore.dart';

enum EventCategory { 
  music, sport, art, tech, 
  food, business, education, 
  entertainment, community, health, 
  gaming, other 
}

enum EventStatus { draft, published }

class EventLocation {
  final double latitude;
  final double longitude;
  final String address;

  EventLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'address': address,
  };

  factory EventLocation.fromJson(Map<String, dynamic> json) => EventLocation(
    latitude: json['latitude'],
    longitude: json['longitude'],
    address: json['address'],
  );
}

class Event {
  final String id;
  final String organizerId;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime startDate;
  final DateTime endDate;
  final EventLocation location;
  final int maxAttendees;
  final int currentAttendees;
  final double? price;
  final EventStatus status;
  final DateTime createdAt;

  Event({
    required this.id,
    required this.organizerId,
    required this.title,
    required this.description,
    required this.category,
    required this.startDate,
    required this.endDate,
    required this.location,
    required this.maxAttendees,
    required this.currentAttendees,
    this.price,
    required this.status,
    required this.createdAt,
  });

  bool get isFull => currentAttendees >= maxAttendees;

  String get availabilityStatus {
    if (isFull) return 'Complet';
    final remaining = maxAttendees - currentAttendees;
    if (remaining <= maxAttendees * 0.1 || remaining <= 2) return 'En attente';
    return 'Disponible';
  }

  Event copyWith({
    String? id,
    String? organizerId,
    String? title,
    String? description,
    EventCategory? category,
    DateTime? startDate,
    DateTime? endDate,
    EventLocation? location,
    int? maxAttendees,
    int? currentAttendees,
    double? price,
    EventStatus? status,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      organizerId: organizerId ?? this.organizerId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      currentAttendees: currentAttendees ?? this.currentAttendees,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'organizerId': organizerId,
    'title': title,
    'description': description,
    'category': category.index,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': Timestamp.fromDate(endDate),
    'location': location.toJson(),
    'maxAttendees': maxAttendees,
    'currentAttendees': currentAttendees,
    'price': price,
    'status': status.index,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      organizerId: json['organizerId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: EventCategory.values[json['category']],
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      location: EventLocation.fromJson(json['location']),
      maxAttendees: json['maxAttendees'] ?? 0,
      currentAttendees: json['currentAttendees'] ?? 0,
      price: json['price']?.toDouble(),
      status: EventStatus.values[json['status']],
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
