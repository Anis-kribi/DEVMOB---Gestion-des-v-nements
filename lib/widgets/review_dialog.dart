import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/review.dart';
import '../../providers/auth_provider.dart';
import '../../services/review_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/premium_button.dart';

class ReviewDialog extends StatefulWidget {
  final String eventId;
  const ReviewDialog({super.key, required this.eventId});

  @override
  State<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _commentController = TextEditingController();
  final _reviewService = ReviewService();
  
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez donner une note (étoiles)'),
        backgroundColor: AppTheme.warningColor,
      ));
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final review = Review(
        id: '',
        userId: user.id,
        eventId: widget.eventId,
        rating: _rating,
        comment: _commentController.text.trim().isEmpty 
            ? null 
            : _commentController.text.trim(),
        createdAt: DateTime.now(),
      );

      await _reviewService.createReview(review);

      if (mounted) {
        Navigator.pop(context, true); // true = success
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppTheme.errorColor,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);

    // Provide keyboard padding for bottom sheet
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: appTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Laisser un avis',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Comment s\'est passé l\'événement ?',
            style: TextStyle(color: appTheme.textSecondaryColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Star Rating
          Center(
            child: RatingBar.builder(
              initialRating: 0,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              glowColor: AppTheme.warningColor,
              unratedColor: appTheme.dividerColor,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star_rounded,
                color: AppTheme.warningColor,
              ),
              onRatingUpdate: (rating) {
                setState(() => _rating = rating);
              },
            ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
          ),
          
          const SizedBox(height: 32),
          
          // Comment box
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: TextStyle(color: appTheme.textPrimaryColor),
            decoration: InputDecoration(
              hintText: 'Partagez votre expérience (optionnel)...',
              hintStyle: TextStyle(color: appTheme.textSecondaryColor),
              filled: true,
              fillColor: appTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
          
          const SizedBox(height: 32),
          
          PremiumButton(
            label: 'Envoyer mon avis',
            icon: Icons.send_rounded,
            isLoading: _isSubmitting,
            onPressed: _submitReview,
            gradient: appTheme.primaryGradient,
            height: 54,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }
}
