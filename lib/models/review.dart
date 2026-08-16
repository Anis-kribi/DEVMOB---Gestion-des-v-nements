class Review {
  final String id;
  final String userId;
  final String eventId;
  final double rating; // 1-5 stars
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool notificationCleared;

  Review({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
    this.notificationCleared = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      eventId: json['eventId']?.toString() ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      comment: json['comment']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']?.toString() ?? '')
          : null,
      notificationCleared: json['notificationCleared'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'notificationCleared': notificationCleared,
    };
  }

  Review copyWith({
    String? id,
    String? userId,
    String? eventId,
    double? rating,
    String? comment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Review(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      eventId: eventId ?? this.eventId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationCleared: notificationCleared ?? this.notificationCleared,
    );
  }
}
