import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'providers/theme_provider.dart';
import 'models/models.dart';
import 'services/services.dart';
import 'views/home/event_list_page.dart';
import 'views/calendar/calendar_page.dart';
import 'views/map/event_map_page.dart';
import 'views/user/my_reservations_page.dart';
import 'views/user/profile_page.dart' as user_views;
import 'views/auth/login_page.dart';
import 'views/admin/admin_dashboard.dart';
import 'views/organizer/organizer_dashboard.dart';
import 'utils/app_theme.dart';
import 'widgets/widgets.dart';

Future<void> _checkAndSeedAdmin() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final adminQuery = await firestore
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();
    if (adminQuery.docs.isEmpty) {
      final adminService = AdminService();
      await adminService.createUser(
          'admin@email.com', 'Admin123!', 'Admin', UserRole.admin);
      print('✅ Admin account seeded: admin@email.com successfully.');
    }
  } catch (e) {
    print('⚠️ Failed to seed admin: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable flutter_animate globally
  Animate.restartOnHotReload = true;

  // Keep status bar transparent for edge-to-edge look
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _checkAndSeedAdmin();
  await initializeDateFormatting('fr_FR', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<EventService>(create: (_) => EventService()),
        Provider<ReservationService>(create: (_) => ReservationService()),
        Provider<AdminService>(create: (_) => AdminService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'DevMob — Événements',
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('fr', 'FR')],
            locale:           const Locale('fr', 'FR'),
            theme:     themeProvider.lightTheme,
            darkTheme:  themeProvider.darkTheme,
            themeMode:  themeProvider.themeMode,
            home: const HomePage(),
            debugShowCheckedModeBanner: false,
            // Hero animations work across routes automatically
            builder: (context, child) {
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  HOME SHELL  (routes auth → role → shell with M3 NavigationBar)
// ══════════════════════════════════════════════════════════════════════════════
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoading) {
          return const _SplashScreen();
        }

        if (!authProvider.isAuthenticated) {
          _selectedIndex = 0;
          return const LoginPage();
        }

        final isAdmin      = authProvider.user?.role == UserRole.admin;
        final isOrganizer  = authProvider.user?.role == UserRole.organisateur;

        if (isAdmin)     return const AdminDashboard();
        if (isOrganizer) return const OrganisateurDashboard();

        // ── Utilisateur shell ──────────────────────────────────────────
        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: const [
              EventListPage(),
              CalendarPage(),
              EventMapPage(),
              MyReservationsPage(),
              user_views.ProfilePage(),
            ],
          ),
          bottomNavigationBar: _PremiumNavBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          ),
        );
      },
    );
  }
}

// ── Premium M3 NavigationBar ──────────────────────────────────────────────────
class _PremiumNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const _PremiumNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      animationDuration: AppTheme.mediumAnimation,
      backgroundColor: appTheme.cardColor,
      surfaceTintColor: Colors.transparent,
      indicatorColor: AppTheme.primaryColor.withOpacity(0.12),
      shadowColor: Colors.black.withOpacity(0.08),
      elevation: 8,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.event_rounded, color: appTheme.textSecondaryColor),
          selectedIcon: Icon(Icons.event_rounded, color: AppTheme.primaryColor),
          label: 'Événements',
        ),
        NavigationDestination(
          icon: Icon(Icons.calendar_month_rounded, color: appTheme.textSecondaryColor),
          selectedIcon: Icon(Icons.calendar_month_rounded, color: AppTheme.primaryColor),
          label: 'Calendrier',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_rounded, color: appTheme.textSecondaryColor),
          selectedIcon: Icon(Icons.map_rounded, color: AppTheme.primaryColor),
          label: 'Carte',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border_rounded, color: appTheme.textSecondaryColor),
          selectedIcon: Icon(Icons.bookmark_rounded, color: AppTheme.primaryColor),
          label: 'Réservations',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline_rounded, color: appTheme.textSecondaryColor),
          selectedIcon: Icon(Icons.person_rounded, color: AppTheme.primaryColor),
          label: 'Profil',
        ),
      ],
    );
  }
}

// ── Animated splash / loading screen ─────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(gradient: appTheme.heroGradient),
          ),
          // Decorative orbs
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 150, height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/images/DevMob.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(begin: const Offset(0.7, 0.7), duration: 600.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 24),
                Text(
                  'DevMob',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                const SizedBox(height: 8),
                Text(
                  'Chargement…',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                const SizedBox(height: 40),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

