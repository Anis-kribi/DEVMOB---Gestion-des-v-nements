import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../models/reservation.dart';
import '../../models/review.dart';
import '../../providers/providers.dart';
import '../../utils/app_theme.dart';
import '../../services/event_service.dart';
import '../../services/review_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/payment_dialog.dart';
import '../../widgets/review_dialog.dart';
import '../reservation/reservation_confirmation_page.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class EventDetailPage extends StatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  int _ticketCount = 1;

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final appTheme = AppTheme.of(context);
    final dateFormat = DateFormat('EEEE dd MMMM yyyy • HH:mm', 'fr_FR');

    return FutureBuilder<Event?>(
      future: EventService().getEventById(widget.eventId),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: appTheme.backgroundColor,
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor)
                  .animate(onPlay: (c) => c.repeat())
                  .rotate(duration: 1000.ms),
            ),
          );
        }

        final event = snapshot.data;

        // Not found
        if (event == null) {
          return Scaffold(
            backgroundColor: appTheme.backgroundColor,
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_busy_rounded,
                      size: 64, color: appTheme.textSecondaryColor),
                  const SizedBox(height: 16),
                  Text('Événement non trouvé',
                      style: theme.textTheme.headlineSmall),
                ],
              ),
            ),
          );
        }

        final catColor = _getCategoryColor(event.category);

        return Scaffold(
          backgroundColor: appTheme.backgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─────────────────────── HERO APP BAR ────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: const Color(0xFF4A00E0), // Deep purple instead of transparent
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Material(
                    color: Colors.black.withOpacity(0.25),
                    shape: const CircleBorder(),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.blurBackground],
                  background: _DetailHeroBackground(
                    catColor: catColor,
                    catLabel: _getCategoryName(event.category),
                    catIcon: _getCategoryIcon(event.category),
                  ),
                  title: Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  titlePadding:
                      const EdgeInsets.only(left: 56, bottom: 16, right: 16),
                ),
              ),

              // ─────────────────────── CONTENT ─────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── 2×2 Info cards ───────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon:  Icons.calendar_today_rounded,
                              title: 'Date',
                              value: dateFormat.format(event.startDate),
                              color: AppTheme.primaryColor,
                              index: 0,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon:  Icons.people_outline_rounded,
                              title: 'Places',
                              value: '${event.currentAttendees}/${event.maxAttendees}',
                              color: AppTheme.accentColor,
                              index: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon:  Icons.location_on_rounded,
                              title: 'Lieu',
                              value: event.location.address.isNotEmpty
                                  ? event.location.address
                                  : 'Non spécifié',
                              color: AppTheme.warningColor,
                              index: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon:  Icons.payments_rounded,
                              title: 'Prix',
                              value: (event.price ?? 0) > 0
                                  ? '${event.price!.toStringAsFixed(0)} DT'
                                  : 'Gratuit',
                              color: AppTheme.successColor,
                              index: 3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Description ──────────────────────────────────
                      Text(
                        'Description',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                      const SizedBox(height: 12),
                      GlassCard(
                        elevated: true,
                        child: Text(
                          event.description.isNotEmpty
                              ? event.description
                              : 'Aucune description disponible.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                          ),
                        ),
                      ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.1),

                      const SizedBox(height: 20),

                      // ── Status badge ─────────────────────────────────
                      _StatusBadge(status: event.status)
                          .animate(delay: 300.ms)
                          .fadeIn()
                          .scale(begin: const Offset(0.85, 0.85)),

                      const SizedBox(height: 32),

                      // ── Reviews Section ──────────────────────────────
                      _buildReviewSection(context, event, theme, appTheme)
                          .animate(delay: 400.ms)
                          .fadeIn()
                          .slideY(begin: 0.1),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ─────────────────────── BOTTOM RESERVE BAR ──────────────────
          bottomNavigationBar:
              _buildBottomBar(context, event, appTheme, theme),
        );
      },
    );
  }

  // ── Bottom reservation bar ────────────────────────────────────────────────
  Widget _buildBottomBar(
    BuildContext context,
    Event event,
    AppTheme appTheme,
    ThemeData theme,
  ) {
    final authProvider = context.watch<AuthProvider>();
    final isFull       = event.currentAttendees >= event.maxAttendees;
    final isOrganizer  = authProvider.user?.role == UserRole.organisateur;
    if (isOrganizer) return const SizedBox.shrink();

    final remaining = event.maxAttendees - event.currentAttendees;

    return Container(
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(appTheme.isDark ? 0.4 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price + stepper row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price summary
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total — $_ticketCount ticket(s)',
                        style: TextStyle(
                          color: appTheme.textSecondaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: AppTheme.fastAnimation,
                        transitionBuilder: (child, anim) =>
                            ScaleTransition(scale: anim, child: child),
                        child: Text(
                          key: ValueKey(_ticketCount),
                          (event.price ?? 0) > 0
                              ? '${((event.price ?? 0) * _ticketCount).toStringAsFixed(0)} DT'
                              : 'Gratuit',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Ticket stepper
                  _TicketStepper(
                    count: _ticketCount,
                    max: remaining,
                    isFull: isFull,
                    appTheme: appTheme,
                    theme: theme,
                    onDecrement: () => setState(() => _ticketCount--),
                    onIncrement: () => setState(() => _ticketCount++),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Reserve button (PremiumButton)
              PremiumButton(
                label: isFull ? 'Complet' : 'Réserver ma place',
                icon: isFull ? Icons.block_rounded : Icons.confirmation_num_rounded,
                onPressed: isFull ? null : () => _makeReservation(context, event),
                gradient: isFull ? null : AppTheme.of(context).heroGradient,
                height: 54,
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _makeReservation(BuildContext context, Event event) async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Veuillez vous connecter pour réserver'),
        backgroundColor: AppTheme.warningColor,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final totalPrice = (event.price ?? 0) * _ticketCount;
    String? paymentId;

    if (totalPrice > 0) {
      // Show payment dialog
      final result = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PaymentDialog(amount: totalPrice),
      );

      if (result == null) {
        // Payment cancelled by user
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Paiement annulé'),
            backgroundColor: AppTheme.warningColor,
          ));
        }
        return;
      }
      paymentId = result as String;
    }

    try {
      if (!context.mounted) return;
      final reservationProvider = context.read<ReservationProvider>();
      
      final reservation = Reservation(
        id: '',
        userId: authProvider.user!.id,
        eventId: event.id,
        numberOfTickets: _ticketCount,
        totalPrice: totalPrice,
        paymentId: paymentId,
        createdAt: DateTime.now(),
      );

      await reservationProvider.createReservation(reservation);
      
      if (context.mounted) {
        // Navigate to confirmation page
        Navigator.push(
          context,
          AppAnimations.premiumRoute(
            page: ReservationConfirmationPage(
              event: event,
              reservation: reservation,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildReviewSection(
      BuildContext context, Event event, ThemeData theme, AppTheme appTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Avis & Commentaires',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            
            // Allow rating for any event as long as user is authenticated
            if (context.watch<AuthProvider>().isAuthenticated)
              TextButton.icon(
                onPressed: () async {
                  final result = await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => ReviewDialog(eventId: event.id),
                  );
                  if (result == true && mounted) {
                    setState(() {}); // refresh
                  }
                },
                icon: const Icon(Icons.add_comment_rounded, size: 20),
                label: const Text('Donner un avis'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        StreamBuilder<List<Review>>(
          stream: ReviewService().getReviewsByEvent(event.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: SelectableText(
                    'Erreur (ex: Il manque un index Firestore) :\n${snapshot.error}',
                    style: const TextStyle(color: AppTheme.errorColor, fontSize: 12),
                  ),
                ),
              );
            }
            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: appTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: appTheme.dividerColor),
                ),
                child: Center(
                  child: Text(
                    'Aucun avis pour le moment',
                    style: TextStyle(color: appTheme.textSecondaryColor),
                  ),
                ),
              );
            }

            final averageRating = reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;

            return Column(
              children: [
                // Average Rating
                GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 12),
                      RatingBarIndicator(
                        rating: averageRating,
                        itemBuilder: (context, index) => const Icon(
                            Icons.star_rounded, color: AppTheme.warningColor),
                        itemCount: 5,
                        itemSize: 24.0,
                        unratedColor: appTheme.dividerColor,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '(${reviews.length})',
                        style: TextStyle(color: appTheme.textSecondaryColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Reviews List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final review = reviews[index];
                    final isOwner = review.userId == event.organizerId;
                    
                    return FutureBuilder<User?>(
                      future: context.read<AuthService>().getUserData(review.userId),
                      builder: (context, snapshot) {
                        final userName = snapshot.data?.name ?? (isOwner ? 'Organisateur' : 'Utilisateur');
                        final initial = userName.isNotEmpty ? userName[0].toUpperCase() : (isOwner ? 'O' : 'U');

                        return GlassCard(
                          elevated: true,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isOwner ? AppTheme.accentColor.withOpacity(0.2) : appTheme.primaryGradient.colors.first.withOpacity(0.2),
                                    child: Text(
                                      initial,
                                      style: TextStyle(
                                        color: isOwner ? AppTheme.accentColor : theme.colorScheme.primary, 
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(userName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                            if (isOwner) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.accentColor.withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text('Créateur', style: TextStyle(color: AppTheme.accentColor, fontSize: 9, fontWeight: FontWeight.bold)),
                                              ),
                                            ]
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          DateFormat('dd MMM yyyy • HH:mm', 'fr_FR').format(review.createdAt),
                                          style: TextStyle(fontSize: 11, color: appTheme.textSecondaryColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.warningColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          review.rating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: AppTheme.warningColor,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(Icons.star_rounded, color: AppTheme.warningColor, size: 14),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (review.comment != null && review.comment!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isOwner ? AppTheme.accentColor.withOpacity(0.05) : (appTheme.isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.04)),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isOwner ? AppTheme.accentColor.withOpacity(0.3) : appTheme.dividerColor.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    review.comment!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: appTheme.textPrimaryColor, 
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ).animate(delay: Duration(milliseconds: 70 * index)).fadeIn(duration: 400.ms).slideX(begin: 0.05);
                      }
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  Color _getCategoryColor(EventCategory c) {
    switch (c) {
      case EventCategory.music: return AppTheme.primaryColor;
      case EventCategory.sport: return AppTheme.successColor;
      case EventCategory.art: return AppTheme.warningColor;
      case EventCategory.tech: return AppTheme.accentColor;
      case EventCategory.food: return Colors.orange;
      case EventCategory.business: return Colors.blueGrey;
      case EventCategory.education: return Colors.indigo;
      case EventCategory.entertainment: return Colors.purpleAccent;
      case EventCategory.community: return Colors.teal;
      case EventCategory.health: return Colors.redAccent;
      case EventCategory.gaming: return Colors.deepPurple;
      case EventCategory.other: return Colors.grey;
    }
  }

  IconData _getCategoryIcon(EventCategory c) {
    switch (c) {
      case EventCategory.music: return Icons.music_note_rounded;
      case EventCategory.sport: return Icons.sports_soccer_rounded;
      case EventCategory.art: return Icons.brush_rounded;
      case EventCategory.tech: return Icons.computer_rounded;
      case EventCategory.food: return Icons.restaurant_rounded;
      case EventCategory.business: return Icons.business_center_rounded;
      case EventCategory.education: return Icons.school_rounded;
      case EventCategory.entertainment: return Icons.movie_rounded;
      case EventCategory.community: return Icons.people_rounded;
      case EventCategory.health: return Icons.favorite_rounded;
      case EventCategory.gaming: return Icons.sports_esports_rounded;
      case EventCategory.other: return Icons.category_rounded;
    }
  }

  String _getCategoryName(EventCategory c) {
    switch (c) {
      case EventCategory.music: return 'Musique';
      case EventCategory.sport: return 'Sport';
      case EventCategory.art: return 'Art';
      case EventCategory.tech: return 'Technologie';
      case EventCategory.food: return 'Gastronomie';
      case EventCategory.business: return 'Business';
      case EventCategory.education: return 'Éducation';
      case EventCategory.entertainment: return 'Divertissement';
      case EventCategory.community: return 'Communauté';
      case EventCategory.health: return 'Santé';
      case EventCategory.gaming: return 'Gaming';
      case EventCategory.other: return 'Autre';
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _DetailHeroBackground extends StatelessWidget {
  final Color catColor;
  final String catLabel;
  final IconData catIcon;

  const _DetailHeroBackground({
    required this.catColor,
    required this.catLabel,
    required this.catIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            catColor.withOpacity(0.9),
            AppTheme.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -50,  right: -50, child: _Bubble(size: 170, opacity: 0.10)),
          Positioned(bottom: -30, left: -30, child: _Bubble(size: 120, opacity: 0.07)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(catIcon, color: Colors.white, size: 32),
                )
                    .animate()
                    .scale(begin: const Offset(0.7, 0.7), duration: 500.ms, curve: Curves.easeOutBack)
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    catLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                )
                    .animate(delay: 150.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size, opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final int index;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);
    final appTheme = AppTheme.of(context);

    return GlassCard(
      elevated: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: appTheme.textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 80 + index * 60))
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.15);
  }
}

class _StatusBadge extends StatelessWidget {
  final EventStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case EventStatus.draft:
        color = AppTheme.warningColor;
        icon  = Icons.edit_rounded;
        label = 'Brouillon';
        break;
      case EventStatus.published:
        color = AppTheme.successColor;
        icon  = Icons.check_circle_rounded;
        label = 'Publié';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketStepper extends StatelessWidget {
  final int count, max;
  final bool isFull;
  final AppTheme appTheme;
  final ThemeData theme;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _TicketStepper({
    required this.count,
    required this.max,
    required this.isFull,
    required this.appTheme,
    required this.theme,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final canDec = count > 1 && !isFull;
    final canInc = count < max && !isFull;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:        appTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(color: appTheme.dividerColor, width: 1),
      ),
      child: Row(
        children: [
          _StepBtn(
            icon: Icons.remove_rounded,
            active: canDec,
            onTap: canDec ? onDecrement : null,
            theme: theme,
            appTheme: appTheme,
          ),
          AnimatedSwitcher(
            duration: AppTheme.fastAnimation,
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Padding(
              key: ValueKey(count),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                '$count',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          _StepBtn(
            icon: Icons.add_rounded,
            active: canInc,
            filled: true,
            onTap: canInc ? onIncrement : null,
            theme: theme,
            appTheme: appTheme,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool filled;
  final VoidCallback? onTap;
  final ThemeData theme;
  final AppTheme appTheme;

  const _StepBtn({
    required this.icon,
    required this.active,
    this.filled = false,
    this.onTap,
    required this.theme,
    required this.appTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active && filled
          ? theme.colorScheme.primary
          : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: active
                ? (filled ? Colors.white : theme.colorScheme.onSurface)
                : appTheme.textTertiaryColor,
          ),
        ),
      ),
    );
  }
}
