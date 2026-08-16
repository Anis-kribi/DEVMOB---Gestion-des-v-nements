enum ReservationStatus { pending, confirmed, cancelled, completed }

class Reservation {
  final String id;
  final String userId;
  final String eventId;
  final int numberOfTickets;
  final double totalPrice;
  final ReservationStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? paymentId; // For payment integration
  final bool notificationCleared;

  Reservation({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.numberOfTickets,
    required this.totalPrice,
    this.status = ReservationStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.paymentId,
    this.notificationCleared = false,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      numberOfTickets: json['numberOfTickets']?.toInt() ?? 0,
      totalPrice: json['totalPrice']?.toDouble() ?? 0.0,
      status: ReservationStatus.values[json['status']?.toInt() ?? 0],
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']?.toString() ?? '')
          : null,
      paymentId: json['paymentId']?.toString(),
      notificationCleared: json['notificationCleared'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'numberOfTickets': numberOfTickets,
      'totalPrice': totalPrice,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'paymentId': paymentId,
      'notificationCleared': notificationCleared,
    };
  }

  Reservation copyWith({
    String? id,
    String? userId,
    String? eventId,
    int? numberOfTickets,
    double? totalPrice,
    ReservationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentId,
    bool? notificationCleared,
  }) {
    return Reservation(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      numberOfTickets: numberOfTickets ?? this.numberOfTickets,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentId: paymentId ?? this.paymentId,
      notificationCleared: notificationCleared ?? this.notificationCleared,
    );
  }
}
