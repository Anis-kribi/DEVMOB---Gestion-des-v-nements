import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a review
  Future<String> createReview(Review review) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('reviews')
          .add(review.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de l\'avis: $e');
    }
  }

  // Get reviews by event
  Stream<List<Review>> getReviewsByEvent(String eventId) {
    return _firestore
        .collection('reviews')
        .where('eventId', isEqualTo: eventId)
        .snapshots()
        .map((snapshot) {
          final lists = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Review.fromJson(data);
          }).toList();
          lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return lists;
        });
  }

  // Get reviews by user
  Stream<List<Review>> getReviewsByUser(String userId) {
    return _firestore
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final lists = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return Review.fromJson(data);
          }).toList();
          lists.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return lists;
        });
  }

  // Get review by ID
  Future<Review?> getReviewById(String reviewId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('reviews')
          .doc(reviewId)
          .get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return Review.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'avis: $e');
    }
  }

  // Update review
  Future<void> updateReview(Review review) async {
    try {
      await _firestore
          .collection('reviews')
          .doc(review.id)
          .update(review.toJson());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de l\'avis: $e');
    }
  }

  // Delete review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection('reviews').doc(reviewId).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'avis: $e');
    }
  }

  // Check if user has reviewed event
  Future<bool> hasUserReviewedEvent(String userId, String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking review: $e');
      return false;
    }
  }

  // Get average rating for event
  Future<double> getAverageRatingForEvent(String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (snapshot.docs.isEmpty) return 0.0;

      double totalRating = 0.0;
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalRating += data['rating'] as double;
      }

      return totalRating / snapshot.docs.length;
    } catch (e) {
      print('Error getting average rating: $e');
      return 0.0;
    }
  }

  // Get total reviews count for event
  Future<int> getTotalReviewsForEvent(String eventId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('reviews')
          .where('eventId', isEqualTo: eventId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      print('Error getting review count: $e');
      return 0;
    }
  }
}
