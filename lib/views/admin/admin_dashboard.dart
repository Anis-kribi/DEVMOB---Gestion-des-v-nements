import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../models/user.dart';
import '../../models/event.dart';
import '../../providers/providers.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_theme.dart';
import '../../views/organizer/create_event_page.dart';
import '../../widgets/admin/admin_widgets.dart';
import '../../widgets/notification_badge.dart';
import 'manage_user_dialog.dart';
import 'admin_profile_page.dart';
import 'admin_notification_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // ── Search / Filter state ──
  final TextEditingController _userSearchController = TextEditingController();
  String _userSearchQuery = '';
  UserRole? _selectedRoleFilter;

  final TextEditingController _eventSearchController = TextEditingController();
  String _eventSearchQuery = '';
  EventCategory? _selectedCategoryFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadUsers();
      context.read<EventProvider>().loadEvents();
      // Start clean real-time notification stream
      context.read<NotificationProvider>().startListening();
    });
  }


  @override
  void dispose() {
    _tabController.dispose();
    _userSearchController.dispose();
    _eventSearchController.dispose();
    super.dispose();
  }

  // ── Actions ──

  void _showAddUserDialog() =>
      showDialog(context: context, builder: (ctx) => const ManageUserDialog());

  void _showEditUserDialog(User user) => showDialog(
      context: context, builder: (ctx) => ManageUserDialog(user: user));

  void _confirmDeleteUser(User user) => _premiumConfirmDialog(
        title: 'Supprimer l\'utilisateur',
        message: 'Voulez-vous vraiment supprimer ${user.name} ?',
        confirmLabel: 'Supprimer',
        icon: Icons.person_off_rounded,
        onConfirm: () {
          context.read<AdminProvider>().deleteUser(user.id).then((_) {
            _showToast('Utilisateur supprimé', success: true);
          }).catchError((e) {
            _showToast(e.toString(), success: false);
          });
        },
      );

  void _confirmDeleteEvent(Event event) => _premiumConfirmDialog(
        title: 'Supprimer l\'événement',
        message: 'Voulez-vous vraiment supprimer "${event.title}" ?',
        confirmLabel: 'Supprimer',
        icon: Icons.event_busy_rounded,
        onConfirm: () {
          context.read<EventProvider>().deleteEvent(event.id).then((_) {
            _showToast('Événement supprimé', success: true);
          }).catchError((e) {
            _showToast(e.toString(), success: false);
          });
        },
      );

  void _premiumConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required IconData icon,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge)),
        backgroundColor: AppTheme.of(context).cardColor,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.errorColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Icon(icon, color: AppTheme.errorColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700))),
          ],
        ),
        content: Text(message,
            style: TextStyle(
                color: AppTheme.of(context).textSecondaryColor,
                fontSize: 14)),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler',
                style:
                    TextStyle(color: AppTheme.of(context).textSecondaryColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showToast(String message, {required bool success}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor:
            success ? AppTheme.successColor : AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final auth = context.watch<AuthProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final eventProvider = context.watch<EventProvider>();

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      floatingActionButton: _buildFab(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(context, appTheme, auth, adminProvider,
              eventProvider, innerBoxIsScrolled),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildUsersTab(adminProvider, auth, appTheme),
            _buildEventsTab(eventProvider, appTheme),
            const AdminProfilePage(),
          ],
        ),
      ),
    );
  }

  // ── Sliver App Bar ──────────────────────────────────────────────────

  Widget _buildSliverAppBar(
    BuildContext context,
    AppTheme appTheme,
    AuthProvider auth,
    AdminProvider adminProvider,
    EventProvider eventProvider,
    bool innerBoxIsScrolled,
  ) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      floating: false,
      elevation: 0,
      backgroundColor: AppTheme.primaryDark,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: appTheme.surfaceColor,
            border: Border(
              bottom: BorderSide(color: appTheme.dividerColor, width: 1),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: appTheme.textSecondaryColor,
            indicatorColor: AppTheme.primaryColor,
            indicatorWeight: 2.5,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            tabs: const [
              Tab(
                icon: Icon(Icons.people_outline_rounded, size: 20),
                text: 'Utilisateurs',
                height: 56,
              ),
              Tab(
                icon: Icon(Icons.event_rounded, size: 20),
                text: 'Événements',
                height: 56,
              ),
              Tab(
                icon: Icon(Icons.manage_accounts_rounded, size: 20),
                text: 'Profil',
                height: 56,
              ),
            ],
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildAppBarBackground(
            context, appTheme, auth, adminProvider, eventProvider),
      ),
      title: innerBoxIsScrolled
          ? Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset('assets/images/DevMob.png',
                      height: 28, width: 28, fit: BoxFit.cover),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Panel Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            )
          : null,
      actions: [
        // ── Notification bell — driven by NotificationProvider ──
        Consumer<NotificationProvider>(
          builder: (context, notifProvider, _) {
            final count = notifProvider.pendingCount;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.push(
                    context,
                    AppAnimations.premiumRoute(
                        page: const AdminNotificationPage()),
                  );
                },
                icon: NotificationBadge(
                  count: count,
                  top: -5,
                  right: -5,
                  child: const Icon(
                    Icons.notifications_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAppBarBackground(
    BuildContext context,
    AppTheme appTheme,
    AuthProvider auth,
    AdminProvider adminProvider,
    EventProvider eventProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2D1B69),
            AppTheme.primaryDark,
            const Color(0xFF1A1040),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Decorative orbs
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withOpacity(0.15),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondaryColor.withOpacity(0.10),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Brand row ──
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset('assets/images/DevMob.png',
                            height: 36, width: 36, fit: BoxFit.cover),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Panel Administration',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Bonjour, ${auth.user?.name ?? "Admin"} 👋',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.15, end: 0),

                  const SizedBox(height: 12),

                  // ── KPI Row ──
                  Row(
                    children: [
                      KpiCard(
                        label: 'Événements',
                        value: eventProvider.events.length,
                        icon: Icons.event_rounded,
                        accentColor: AppTheme.accentColor,
                        animationDelay: 100,
                      ),
                      const SizedBox(width: 10),
                      KpiCard(
                        label: 'Utilisateurs',
                        value: adminProvider.users
                            .where((u) => u.role == UserRole.utilisateur)
                            .length,
                        icon: Icons.people_outline_rounded,
                        accentColor: AppTheme.primaryColor,
                        animationDelay: 180,
                      ),
                      const SizedBox(width: 10),
                      KpiCard(
                        label: 'Organisateurs',
                        value: adminProvider.users
                            .where((u) => u.role == UserRole.organisateur)
                            .length,
                        icon: Icons.business_center_rounded,
                        accentColor: const Color(0xFF6366F1), // Indigo
                        animationDelay: 260,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────

  Widget? _buildFab(BuildContext context) {
    if (_tabController.index == 0) {
      return FloatingActionButton.extended(
        heroTag: 'fab_user',
        onPressed: _showAddUserDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.person_add_rounded, size: 20),
        label: const Text('Utilisateur',
            style: TextStyle(fontWeight: FontWeight.w700)),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOutBack);
    }
    if (_tabController.index == 1) {
      return FloatingActionButton.extended(
        heroTag: 'fab_event',
        onPressed: () => Navigator.push(
          context,
          AppAnimations.premiumRoute(page: const CreateEventPage()),
        ),
        backgroundColor: AppTheme.accentColor,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
        label: const Text('Événement',
            style: TextStyle(fontWeight: FontWeight.w700)),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.8, 0.8), duration: 300.ms, curve: Curves.easeOutBack);
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────
  // TAB 1 — USERS
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildUsersTab(
      AdminProvider adminProvider, AuthProvider auth, AppTheme appTheme) {
    if (adminProvider.isLoading && adminProvider.users.isEmpty) {
      return _buildSkeletonList();
    }
    if (adminProvider.error != null && adminProvider.users.isEmpty) {
      return _buildErrorState(
          adminProvider.error!, adminProvider.loadUsers, appTheme);
    }

    final filtered = adminProvider.users.where((u) {
      final q = _userSearchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          u.name.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q);
      final matchRole =
          _selectedRoleFilter == null || u.role == _selectedRoleFilter;
      return matchSearch && matchRole;
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: AdminSearchBar(
            controller: _userSearchController,
            hintText: 'Rechercher un utilisateur...',
            onChanged: (v) => setState(() => _userSearchQuery = v),
            filterButton: AdminFilterButton(
              isActive: _selectedRoleFilter != null,
              tooltip: 'Filtrer par rôle',
              onSelected: (v) {
                setState(() {
                  if (v == 'all') {
                    _selectedRoleFilter = null;
                  } else {
                    _selectedRoleFilter = v as UserRole?;
                  }
                });
              },
              itemBuilder: (_) => [
                const PopupMenuItem<dynamic>(
                    value: 'all', child: Text('Tous les rôles')),
                ...UserRole.values.map((r) => PopupMenuItem<dynamic>(
                      value: r,
                      child: Row(children: [
                        Icon(AdminUserTile.roleIcon(r),
                            size: 16,
                            color: AdminUserTile.roleColor(r)),
                        const SizedBox(width: 8),
                        Text(AdminUserTile.roleLabel(r)),
                      ]),
                    )),
              ],
            ),
          ),
        ),
        // Count label
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} utilisateur(s)',
              style: TextStyle(
                  color: appTheme.textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        // List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(
                  icon: Icons.people_outline_rounded,
                  message: 'Aucun utilisateur trouvé',
                  appTheme: appTheme,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final user = filtered[i];
                    return AdminUserTile(
                      user: user,
                      isCurrentUser: user.id == auth.user?.id,
                      animationIndex: i,
                      onEdit: () => _showEditUserDialog(user),
                      onDelete: () => _confirmDeleteUser(user),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // TAB 2 — EVENTS
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildEventsTab(EventProvider eventProvider, AppTheme appTheme) {
    if (eventProvider.isLoading && eventProvider.events.isEmpty) {
      return _buildSkeletonList();
    }

    final filtered = eventProvider.events.where((e) {
      final q = _eventSearchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          e.title.toLowerCase().contains(q) ||
          e.location.address.toLowerCase().contains(q);
      final matchCat = _selectedCategoryFilter == null ||
          e.category == _selectedCategoryFilter;
      return matchSearch && matchCat;
    }).toList();

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: AdminSearchBar(
            controller: _eventSearchController,
            hintText: 'Rechercher un événement...',
            onChanged: (v) => setState(() => _eventSearchQuery = v),
            filterButton: AdminFilterButton(
              isActive: _selectedCategoryFilter != null,
              tooltip: 'Filtrer par catégorie',
              onSelected: (v) {
                setState(() {
                  if (v == 'all') {
                    _selectedCategoryFilter = null;
                  } else {
                    _selectedCategoryFilter = v as EventCategory?;
                  }
                });
              },
              itemBuilder: (_) => [
                const PopupMenuItem<dynamic>(
                    value: 'all', child: Text('Toutes catégories')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.music,
                    child: Text('🎵 Musique')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.sport,
                    child: Text('⚽ Sport')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.art,
                    child: Text('🎨 Art')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.tech,
                    child: Text('💻 Tech')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.food,
                    child: Text('🍔 Gastronomie')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.business,
                    child: Text('💼 Business')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.education,
                    child: Text('🎓 Éducation')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.entertainment,
                    child: Text('🎬 Divertissement')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.community,
                    child: Text('🤝 Communauté')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.health,
                    child: Text('⚕️ Santé')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.gaming,
                    child: Text('🎮 Gaming')),
                const PopupMenuItem<dynamic>(
                    value: EventCategory.other,
                    child: Text('📌 Autre')),
              ],
            ),
          ),
        ),
        // Count label
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${filtered.length} événement(s)',
              style: TextStyle(
                  color: appTheme.textSecondaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ),
        // List
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_busy_rounded,
                  message: 'Aucun événement trouvé',
                  appTheme: appTheme,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final event = filtered[i];
                    return AdminEventTile(
                      event: event,
                      animationIndex: i,
                      onEdit: () => Navigator.push(
                        context,
                        AppAnimations.premiumRoute(
                          page: CreateEventPage(eventToEdit: event),
                        ),
                      ),
                      onDelete: () => _confirmDeleteEvent(event),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────

  Widget _buildSkeletonList() {
    final appTheme = AppTheme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, i) => Container(
        height: 80,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: appTheme.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: appTheme.dividerColor),
        ),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 1200.ms,
            color: appTheme.isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.6),
          ),
    );
  }

  Widget _buildErrorState(
      String error, VoidCallback onRetry, AppTheme appTheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded,
                size: 36, color: AppTheme.errorColor),
          ),
          const SizedBox(height: 16),
          Text('Erreur de chargement',
              style: TextStyle(
                  color: appTheme.textPrimaryColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
          const SizedBox(height: 6),
          Text(error,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: appTheme.textSecondaryColor, fontSize: 13)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required AppTheme appTheme,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon,
                size: 40, color: AppTheme.primaryColor.withOpacity(0.5)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: appTheme.textSecondaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(begin: const Offset(0.9, 0.9), duration: 400.ms),
    );
  }
}
