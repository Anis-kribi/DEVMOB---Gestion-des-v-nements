import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../models/user.dart';
import '../home/event_list_page.dart';
import '../user/profile_page.dart';
import 'create_event_page.dart';
import '../notifications/notification_page.dart';
import 'organizer_stats_page.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/notification_badge.dart';
import '../../utils/app_theme.dart';

class OrganisateurDashboard extends StatefulWidget {
  const OrganisateurDashboard({super.key});

  @override
  State<OrganisateurDashboard> createState() => _OrganisateurDashboardState();
}

class _OrganisateurDashboardState extends State<OrganisateurDashboard> {
  int _selectedIndex = 0;
  List<String> _lastEventIds = [];
  NotificationProvider? _notifProv;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _notifProv = context.read<NotificationProvider>();
        _notifProv?.addListener(_onNotifChange);
      }
    });
  }

  void _onNotifChange() {
    if (_notifProv?.freshlyAddedReservation != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text("Nouvelle réservation reçue !")),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }

    if (_notifProv?.freshlyAddedReview != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.comment_rounded, color: Colors.white),
              const SizedBox(width: 10),
              const Expanded(child: Text("Nouveau commentaire sur votre événement !")),
            ],
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncNotificationStream();
  }

  void _syncNotificationStream() {
    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.watch<EventProvider>(); // Watch purely to react to event changes
    
    if (authProvider.user == null) return;

    final myEventIds = eventProvider.events
        .where((e) => e.organizerId == authProvider.user!.id)
        .map((e) => e.id)
        .toList();

    // Only restart listening if the list of my events actually changed
    if (myEventIds.length != _lastEventIds.length || !myEventIds.every((id) => _lastEventIds.contains(id))) {
      _lastEventIds = myEventIds;
      context.read<NotificationProvider>().startListening(
        eventIds: myEventIds,
        organizerId: authProvider.user?.id,
      );
    }
  }

  @override
  void dispose() {
    _notifProv?.removeListener(_onNotifChange);
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null || user.role != UserRole.organisateur) {
      return const Scaffold(body: Center(child: Text('Accès non autorisé')));
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildMyEventsTab(context),
          const OrganizerStatsPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: _buildNavBar(context),
      floatingActionButton: _selectedIndex == 0
          ? _buildFab(context)
          : null,
    );
  }

  Widget _buildNavBar(BuildContext context) {
    final appTheme = AppTheme.of(context);
    return NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      backgroundColor: appTheme.cardColor,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppTheme.primaryColor.withOpacity(0.12),
      elevation: 8,
      height: 68,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.event_note_rounded,
              color: appTheme.textSecondaryColor),
          selectedIcon:
              Icon(Icons.event_note_rounded, color: AppTheme.primaryColor),
          label: 'Mes Événements',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_rounded,
              color: appTheme.textSecondaryColor),
          selectedIcon:
              Icon(Icons.bar_chart_rounded, color: AppTheme.primaryColor),
          label: 'Statistiques',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded,
              color: appTheme.textSecondaryColor),
          selectedIcon:
              Icon(Icons.person_rounded, color: AppTheme.primaryColor),
          label: 'Profil',
        ),
      ],
    );
  }

  Widget _buildFab(BuildContext context) {
    final appTheme = AppTheme.of(context);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateEventPage()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: appTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: appTheme.buttonShadow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
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
    );
  }

  Widget _buildMyEventsTab(BuildContext context) {
    return EventListPage(
      title: 'Mes Événements',
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Consumer<NotificationProvider>(
              builder: (context, notifProvider, _) {
                final count = notifProvider.pendingCount;
                return IconButton(
                  icon: NotificationBadge(
                    count: count,
                    top: 2,
                    right: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        color: Theme.of(context).colorScheme.primary,
                        size: 26,
                      ),
                    ),
                  ),
                  onPressed: () {
                    final eventProvider = context.read<EventProvider>();
                    final authProvider = context.read<AuthProvider>();
                    final myEventIds = eventProvider.events
                        .where((e) => e.organizerId == authProvider.user?.id)
                        .map((e) => e.id)
                        .toList();

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NotificationPage(eventIds: myEventIds)),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
