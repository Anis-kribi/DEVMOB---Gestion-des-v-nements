import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/event.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../widgets/location_picker_dialog.dart';
import '../../widgets/premium_button.dart';

class CreateEventPage extends StatefulWidget {
  final Event? eventToEdit;

  const CreateEventPage({super.key, this.eventToEdit});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  EventCategory? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _pickedLat;
  double? _pickedLng;
  String? _selectedState;
  
  final List<String> _tunisiaStates = [
    'Ariana', 'Béja', 'Ben Arous', 'Bizerte', 'Gabès', 'Gafsa', 'Jendouba', 'Kairouan',
    'Kasserine', 'Kébili', 'Le Kef', 'Mahdia', 'La Manouba', 'Médenine', 'Monastir',
    'Nabeul', 'Sfax', 'Sidi Bouzid', 'Siliana', 'Sousse', 'Tataouine', 'Tozeur', 'Tunis', 'Zaghouan'
  ]..sort();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _initializeWithEvent(widget.eventToEdit!);
    }
  }

  void _initializeWithEvent(Event event) {
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _addressController.text = event.location.address;
    _seatsController.text = event.maxAttendees.toString();
    _priceController.text = event.price?.toString() ?? '';
    _selectedCategory = event.category;
    _startDate = event.startDate;
    _endDate = event.endDate;
    _pickedLat = event.location.latitude;
    _pickedLng = event.location.longitude;
    
    if (_tunisiaStates.contains(event.location.address)) {
      _selectedState = event.location.address;
    } else if (event.location.address.isNotEmpty) {
      _selectedState = 'Tunis'; // Fallback
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _seatsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _startDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _endDate = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickLocation() async {
    // Show location picker dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const LocationPickerDialog(),
    );

    if (result != null) {
      setState(() {
        _pickedLat = result['latitude'];
        _pickedLng = result['longitude'];
        _addressController.text = result['address'];
      });
    }
  }

  String _getCategoryLabel(EventCategory category) {
    switch (category) {
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

  Future<void> _submit() async {
    if (_isLoading) return;

    final authProvider = context.read<AuthProvider>();
    final eventProvider = context.read<EventProvider>();

    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      _showSnackBar('Veuillez sélectionner une catégorie', isError: true);
      return;
    }
    if (_startDate == null || _endDate == null) {
      _showSnackBar(
        'Veuillez sélectionner les dates de début et de fin',
        isError: true,
      );
      return;
    }
    if (_selectedState == null) {
      _showSnackBar('Veuillez sélectionner un gouvernorat', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final isEditing = widget.eventToEdit != null;

    final event = Event(
      id: isEditing ? widget.eventToEdit!.id : '',
      organizerId: authProvider.user!.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      startDate: _startDate!,
      endDate: _endDate!,
      location: EventLocation(
        latitude: _pickedLat ?? 33.8869,
        longitude: _pickedLng ?? 9.5375,
        address: _selectedState!,
      ),
      maxAttendees: int.tryParse(_seatsController.text) ?? 0,
      currentAttendees: isEditing ? widget.eventToEdit!.currentAttendees : 0,
      price: double.tryParse(_priceController.text),
      status: EventStatus.published,
      createdAt: isEditing ? widget.eventToEdit!.createdAt : DateTime.now(),
    );

    try {
      if (isEditing) {
        await eventProvider.updateEvent(event);
        await eventProvider.refreshEvents();
        if (!mounted) return;
        _showSnackBar('Événement modifié avec succès !', isError: false);
      } else {
        await eventProvider.addEvent(event);
        await eventProvider.refreshEvents();
        if (!mounted) return;
        _showSnackBar('Événement créé avec succès !', isError: false);
      }
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erreur: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE d MMMM yyyy à HH:mm', 'fr_FR');
    final primaryColor = theme.colorScheme.primary;
    final cardColor = theme.cardColor;
    final bgColor = theme.scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          widget.eventToEdit != null
              ? 'Modifier l\'événement'
              : 'Créer un événement',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [primaryColor, primaryColor.withOpacity(0.15)],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.event_note,
                  size: 60,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(
                      'Informations générales',
                      Icons.info_outline,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _titleController,
                      label: 'Titre de l\'événement',
                      hint: 'Ex: Conférence Tech 2026',
                      icon: Icons.title,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Veuillez entrer un titre'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Décrivez votre événement...',
                      icon: Icons.description,
                      maxLines: 4,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Veuillez entrer une description'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryDropdown(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Date et heure', Icons.calendar_today),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimeCard(
                            label: 'Début',
                            dateTime: _startDate,
                            onTap: _pickStartDate,
                            icon: Icons.event_available,
                            dateFormat: dateFormat,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateTimeCard(
                            label: 'Fin',
                            dateTime: _endDate,
                            onTap: _pickEndDate,
                            icon: Icons.event_busy,
                            dateFormat: dateFormat,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Gouvernorat', Icons.map),
                    const SizedBox(height: 16),
                    _buildStateDropdown(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Capacité et tarif', Icons.people),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _seatsController,
                            label: 'Nombre de places',
                            hint: '100',
                            icon: Icons.event_seat,
                            keyboardType: TextInputType.number,
                            validator: (v) =>
                                v == null || v.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            controller: _priceController,
                            label: 'Prix (DT)',
                            hint: '0.00',
                            icon: Icons.money,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    PremiumButton(
                      label: widget.eventToEdit != null
                          ? 'Modifier l\'événement'
                          : 'Créer l\'événement',
                      icon: Icons.check_circle_rounded,
                      isLoading: _isLoading,
                      onPressed: _isLoading ? null : _submit,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF6366F1), size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6366F1),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final primaryColor = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final primaryColor = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<EventCategory>(
        value: _selectedCategory,
        dropdownColor: cardColor,
        decoration: InputDecoration(
          labelText: 'Catégorie',
          prefixIcon: Icon(Icons.category, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: EventCategory.values
            .map(
              (e) =>
                  DropdownMenuItem(value: e, child: Text(_getCategoryLabel(e))),
            )
            .toList(),
        onChanged: (v) => setState(() => _selectedCategory = v),
        validator: (v) => v == null ? 'Veuillez choisir une catégorie' : null,
      ),
    );
  }

  Widget _buildDateTimeCard({
    required String label,
    required DateTime? dateTime,
    required VoidCallback onTap,
    required IconData icon,
    required DateFormat dateFormat,
  }) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final primaryColor = theme.colorScheme.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: dateTime != null ? primaryColor : theme.dividerColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: dateTime != null ? primaryColor : theme.hintColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dateTime != null ? primaryColor : theme.hintColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              dateTime == null ? 'Sélectionner' : dateFormat.format(dateTime),
              style: TextStyle(
                fontSize: 12,
                color: dateTime != null ? theme.textTheme.bodyMedium?.color : theme.hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateDropdown() {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final primaryColor = theme.colorScheme.primary;
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedState,
        dropdownColor: cardColor,
        decoration: InputDecoration(
          labelText: 'Gouvernorat',
          prefixIcon: Icon(Icons.location_city, color: primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: _tunisiaStates
            .map(
              (state) => DropdownMenuItem(value: state, child: Text(state)),
            )
            .toList(),
        onChanged: (v) => setState(() => _selectedState = v),
        validator: (v) => v == null ? 'Veuillez choisir un gouvernorat' : null,
      ),
    );
  }
}
