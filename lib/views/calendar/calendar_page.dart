import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../models/event.dart';
import '../../models/user.dart';
import '../../providers/event_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/event_card.dart';
import '../../widgets/premium_hero_background.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  List<Event> _getEventsForDay(DateTime day, List<Event> allEvents, User? user) {
    bool isOrganizer = user?.role == UserRole.organisateur;
    
    return allEvents.where((event) {
      if (isOrganizer && event.organizerId != user?.id) {
        return false;
      }
      return isSameDay(event.startDate, day);
    }).toList();
  }

  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.music: return Icons.music_note_rounded;
      case EventCategory.sport: return Icons.sports_soccer_rounded;
      case EventCategory.art: return Icons.palette_rounded;
      case EventCategory.tech: return Icons.computer_rounded;
      case EventCategory.food: return Icons.restaurant_rounded;
      case EventCategory.business: return Icons.business_center_rounded;
      case EventCategory.education: return Icons.school_rounded;
      case EventCategory.entertainment: return Icons.theater_comedy_rounded;
      case EventCategory.community: return Icons.people_rounded;
      case EventCategory.health: return Icons.favorite_rounded;
      case EventCategory.gaming: return Icons.sports_esports_rounded;
      case EventCategory.other: return Icons.event_note_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appTheme = AppTheme.of(context);
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryColor,
            surfaceTintColor: Colors.transparent,
            shape: const ContinuousRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.blurBackground],
              titlePadding: const EdgeInsets.only(left: 24, bottom: 20),
              title: Text(
                authProvider.user?.role == UserRole.organisateur 
                    ? 'Mes Sessions' 
                    : 'Calendrier',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
              background: PremiumHeroBackground(isDark: appTheme.isDark),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Consumer<EventProvider>(
              builder: (context, eventProvider, _) {
                final events = eventProvider.events;
                final selectedEvents = _getEventsForDay(_selectedDay!, events, authProvider.user);

                return Column(
                  children: [
                    // Calendar Widget
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appTheme.cardColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: TableCalendar<Event>(
                        locale: 'fr_FR',
                        firstDay: DateTime.utc(2020, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          }
                        },
                        eventLoader: (day) => _getEventsForDay(day, events, authProvider.user),
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (events.isEmpty) return null;
                            
                            if (events.length == 1) {
                              return Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentColor.withOpacity(0.4),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(events.first.category),
                                    size: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            } else {
                              // Design pour jours à événements multiples
                              return Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    gradient: appTheme.primaryGradient,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryColor.withOpacity(0.4),
                                        blurRadius: 4,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    '+${events.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: appTheme.textPrimaryColor,
                          ),
                          leftChevronIcon: Icon(Icons.chevron_left_rounded, color: appTheme.textSecondaryColor),
                          rightChevronIcon: Icon(Icons.chevron_right_rounded, color: appTheme.textSecondaryColor),
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                          weekendTextStyle: TextStyle(color: AppTheme.errorColor),
                          defaultTextStyle: TextStyle(color: appTheme.textPrimaryColor),
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: TextStyle(color: appTheme.textSecondaryColor, fontWeight: FontWeight.w600),
                          weekendStyle: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                    
                    const SizedBox(height: 16),
                    
                    // Selected Day's Events Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE d MMMM', 'fr_FR').format(_selectedDay!),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: appTheme.textPrimaryColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: appTheme.heroGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ],
                            ),
                            child: Text(
                              '${selectedEvents.length} évent${selectedEvents.length > 1 ? "s" : ""}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const SizedBox(height: 16),
                    
                    // Events List
                    if (selectedEvents.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.event_available_rounded, size: 48, color: AppTheme.primaryColor.withOpacity(0.6)),
                            ).animate(onPlay: (c) => c.repeat(reverse: true))
                                .scale(begin: const Offset(1, 1), end: const Offset(1.06, 1.06), duration: 2000.ms, curve: Curves.easeInOut),
                            const SizedBox(height: 16),
                            Text(
                              'Rien de prévu ce jour.',
                              style: TextStyle(color: appTheme.textSecondaryColor, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms)
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: selectedEvents.length,
                        itemBuilder: (context, index) {
                          return EventCard(
                            event: selectedEvents[index],
                            animationIndex: index,
                          );
                        },
                      ),
                      
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
