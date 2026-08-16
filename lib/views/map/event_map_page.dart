import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../user/event_detail_page.dart';

class EventMapPage extends StatefulWidget {
  const EventMapPage({super.key});

  @override
  State<EventMapPage> createState() => _EventMapPageState();
}

class _EventMapPageState extends State<EventMapPage> {
  final MapController _mapController = MapController();
  Position? _currentPosition;
  Event? _selectedEvent;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 5),
      );
    } catch (e) {
      print('Location error: $e');
    }
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (_currentPosition != null) {
        _mapController.move(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 
          13.0
        );
      }
    }
  }

  void _showEventBottomSheet(Event event) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _EventMapCard(event: event),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    
    final initialCenter = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(36.8065, 10.1815);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Carte des événements'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                appTheme.backgroundColor.withOpacity(0.8),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : Consumer2<EventProvider, AuthProvider>(
              builder: (context, provider, auth, _) {
                final events = provider.events;
                final markers = <Marker>[];
                final currentUser = auth.user;
                final random = Random(42); // Fixed seed for stable positions

                // Marqueurs d'événements
                for (var event in events) {
                  double lat = event.location.latitude;
                  double lng = event.location.longitude;

                  // If location is zero or invalid, place it arbitrarily near Tunis
                  if (lat == 0.0 || lng == 0.0) {
                    lat = 36.8065 + (random.nextDouble() - 0.5) * 0.1;
                    lng = 10.1815 + (random.nextDouble() - 0.5) * 0.1;
                  }

                  final isMyEvent = currentUser != null && event.organizerId == currentUser.id;
                  final markerColor = isMyEvent ? AppTheme.successColor : AppTheme.primaryColor;

                  markers.add(
                    Marker(
                      point: LatLng(lat, lng),
                      width: 50,
                      height: 50,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedEvent = event);
                          _showEventBottomSheet(event);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: markerColor.withOpacity(0.4),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Icon(
                            isMyEvent ? Icons.star_rounded : Icons.location_on_rounded, 
                            color: markerColor, 
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // URL template
                final tileUrl = appTheme.isDark 
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';

                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: initialCenter,
                    initialZoom: 11.0,
                    onTap: (_, __) => setState(() => _selectedEvent = null),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: tileUrl,
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.devmob',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                );
              },
            ).animate().fadeIn(duration: 500.ms),
      floatingActionButton: FloatingActionButton(
        onPressed: _determinePosition,
        backgroundColor: appTheme.cardColor,
        child: Icon(Icons.my_location_rounded, color: AppTheme.primaryColor),
      ),
    );
  }
}

class _EventMapCard extends StatelessWidget {
  final Event event;

  const _EventMapCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final appTheme = AppTheme.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy • HH:mm', 'fr_FR');

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              AppAnimations.premiumRoute(page: EventDetailPage(eventId: event.id)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: appTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.event_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            event.location.address,
                            style: TextStyle(color: appTheme.textSecondaryColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      dateFormat.format(event.startDate),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        (event.price ?? 0) > 0 ? '${event.price?.toStringAsFixed(0)} DT' : 'Gratuit',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        AppAnimations.premiumRoute(page: EventDetailPage(eventId: event.id)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Voir l\'événement'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }
}
