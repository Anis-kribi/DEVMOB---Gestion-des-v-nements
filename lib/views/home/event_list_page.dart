import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../utils/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/shimmer_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/premium_hero_background.dart';
import '../user/event_detail_page.dart';
import '../organizer/create_event_page.dart';
import '../organizer/event_reservations_page.dart';

class EventListPage extends StatefulWidget {
  final String? title;
  final List<Widget>? actions;

  const EventListPage({super.key, this.title, this.actions});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  EventCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Event> _filter(List<Event> events, AuthProvider auth) {
    return events.where((e) {
      final matchSearch = _searchQuery.isEmpty ||
          e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          e.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchCat = _selectedCategory == null || e.category == _selectedCategory;
      final isOrg    = auth.user?.role == UserRole.organisateur;
      final matchOrg = !isOrg || e.organizerId == auth.user?.id;
      return matchSearch && matchCat && matchOrg;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    final appTheme     = AppTheme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isOrganizer  = authProvider.user?.role == UserRole.organisateur;

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: RefreshIndicator(
        color: AppTheme.primaryColor,
        backgroundColor: appTheme.cardColor,
        onRefresh: () => context.read<EventProvider>().refreshEvents(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ─────────────────────────────────────────────────────────
            //  PREMIUM SLIVER APP BAR
            // ─────────────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 180,
              toolbarHeight: 80,
              pinned: true,
              stretch: true,
              backgroundColor: AppTheme.primaryColor,
              surfaceTintColor: Colors.transparent,
              shape: const ContinuousRectangleBorder(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
              ),
              actions: widget.actions,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.blurBackground],
                titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Hero(
                      tag: 'app-logo',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/DevMob.png',
                          height: 64,
                          width: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.title ?? 'Événements',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                background: PremiumHeroBackground(isDark: appTheme.isDark),
              ),
            ),

            // ─────────────────────────────────────────────────────────
            //  SEARCH BAR (glassmorphic)
            // ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: GlassCard(
                  elevated: false,
                  borderRadius: AppTheme.radiusMedium,
                  padding: EdgeInsets.zero,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: TextStyle(
                        color: appTheme.textPrimaryColor, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Rechercher un événement…',
                      prefixIcon: Icon(Icons.search_rounded,
                          color: appTheme.textSecondaryColor),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded,
                                  color: appTheme.textSecondaryColor),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.1),
              ),
            ),

            // ─────────────────────────────────────────────────────────
            //  ANIMATED FILTER CHIPS
            // ─────────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  children: [
                    _AnimatedFilterChip(
                      label: 'Tous',
                      isSelected: _selectedCategory == null,
                      onTap: () => setState(() => _selectedCategory = null),
                      index: 0,
                    ),
                    ...EventCategory.values.toList().asMap().entries.map(
                          (e) => _AnimatedFilterChip(
                            label: _catName(e.value),
                            isSelected: _selectedCategory == e.value,
                            onTap: () =>
                                setState(() => _selectedCategory = e.value),
                            index: e.key + 1,
                          ),
                        ),
                  ],
                ),
              ),
            ),

            // ─────────────────────────────────────────────────────────
            //  EVENT LIST  (shimmer → staggered cards)
            // ─────────────────────────────────────────────────────────
            Consumer<EventProvider>(
              builder: (context, provider, _) {
                // Loading skeleton
                if (provider.isLoading) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const ShimmerCard(),
                      childCount: 4,
                    ),
                  );
                }

                final events = _filter(provider.events, authProvider);

                if (events.isEmpty) {
                  return SliverFillRemaining(
                    child: _EmptyState(
                      message: provider.error ?? 'Essayez de modifier vos filtres',
                      onRefresh: provider.refreshEvents,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.only(top: 4, bottom: 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final event = events[index];
                        return EventCard(
                          key: ValueKey(event.id),
                          event: event,
                          animationIndex: index,
                          showActions: isOrganizer &&
                              event.organizerId == authProvider.user?.id,
                          onTap: () => Navigator.push(
                            context,
                            AppAnimations.premiumRoute(
                              page: EventDetailPage(eventId: event.id),
                            ),
                          ),
                          onEdit: () => Navigator.push(
                            context,
                            AppAnimations.premiumRoute(
                              page: CreateEventPage(eventToEdit: event),
                            ),
                          ),
                          onDelete: () => _confirmDelete(event, provider),
                          onViewReservations: () => Navigator.push(
                            context,
                            AppAnimations.premiumRoute(
                              page: EventReservationsPage(event: event),
                            ),
                          ),
                        );
                      },
                      childCount: events.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: isOrganizer
          ? _PremiumFab(
              onPressed: () => Navigator.push(
                context,
                AppAnimations.premiumRoute(
                    page: const CreateEventPage()),
              ),
            )
          : null,
    );
  }

  void _confirmDelete(Event event, EventProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) {
        final appTheme = AppTheme.of(ctx);
        return AlertDialog(
          backgroundColor: appTheme.cardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_rounded,
                    color: AppTheme.errorColor, size: 22),
              ),
              const SizedBox(width: 12),
              const Text('Supprimer', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: Text(
            'Voulez-vous vraiment supprimer "${event.title}" ?\nCette action est irréversible.',
            style: TextStyle(color: appTheme.textSecondaryColor, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Annuler',
                  style: TextStyle(color: appTheme.textSecondaryColor,
                      fontWeight: FontWeight.w600)),
            ),
            FilledButton.icon(
              onPressed: () {
                provider.deleteEvent(event.id);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.delete_rounded, size: 16),
              label: const Text('Supprimer'),
              style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull))),
            ),
          ],
        );
      },
    );
  }

  String _catName(EventCategory c) {
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

/// Animated, scale-press filter chip
class _AnimatedFilterChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int index;

  const _AnimatedFilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.index,
  });

  @override
  State<_AnimatedFilterChip> createState() => _AnimatedFilterChipState();
}

class _AnimatedFilterChipState extends State<_AnimatedFilterChip>
    with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _scale = 0.92),
        onTapUp:   (_) => setState(() => _scale = 1.0),
        onTapCancel: ()  => setState(() => _scale = 1.0),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 80),
          child: AnimatedContainer(
            duration: AppTheme.fastAnimation,
            curve: AppTheme.springCurve,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
            decoration: BoxDecoration(
              gradient: widget.isSelected ? appTheme.primaryGradient : null,
              color:    widget.isSelected ? null : appTheme.cardColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.transparent
                    : appTheme.dividerColor,
                width: 1,
              ),
              boxShadow: widget.isSelected ? appTheme.buttonShadow : [],
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.isSelected
                    ? Colors.white
                    : appTheme.textSecondaryColor,
                fontWeight:
                    widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 40 * widget.index))
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.2);
  }
}

/// Premium FAB (Hero-animatable)
class _PremiumFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _PremiumFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    return Hero(
      tag: 'create-event-fab',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: appTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: appTheme.buttonShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Créer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty-state widget with pulse animation
class _EmptyState extends StatelessWidget {
  final String message;
  final VoidCallback onRefresh;

  const _EmptyState({required this.message, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final theme    = Theme.of(context);


    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 52,
              color: AppTheme.primaryColor,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06),
                  duration: 2000.ms, curve: Curves.easeInOut),
          const SizedBox(height: 20),
          Text(
            'Aucun événement trouvé',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ).animate(delay: 100.ms).fadeIn(),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Rafraîchir'),
          ).animate(delay: 200.ms).fadeIn().scale(
              begin: const Offset(0.9, 0.9)),
        ],
      ),
    );
  }
}
