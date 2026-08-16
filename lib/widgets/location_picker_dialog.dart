import 'package:flutter/material.dart';

class LocationPickerDialog extends StatefulWidget {
  const LocationPickerDialog({super.key});

  @override
  State<LocationPickerDialog> createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  // Common Tunisia locations
  final List<Map<String, dynamic>> _tunisiaLocations = [
    {'name': 'Tunis', 'lat': 36.8065, 'lng': 10.1815},
    {'name': 'Sfax', 'lat': 34.7395, 'lng': 10.5900},
    {'name': 'Sousse', 'lat': 35.8254, 'lng': 10.6410},
    {'name': 'Kairouan', 'lat': 35.6764, 'lng': 10.1056},
    {'name': 'Bizerte', 'lat': 37.2744, 'lng': 9.8739},
    {'name': 'Gabès', 'lat': 33.8817, 'lng': 9.9602},
    {'name': 'Ariana', 'lat': 36.8667, 'lng': 10.1667},
    {'name': 'Gafsa', 'lat': 34.4150, 'lng': 9.4702},
    {'name': 'Monastir', 'lat': 35.7647, 'lng': 10.8232},
    {'name': 'Kasserine', 'lat': 35.1670, 'lng': 8.8368},
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sélectionner le lieu'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Villes populaires en Tunisie:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tunisiaLocations.map((location) {
                  return ActionChip(
                    label: Text(location['name']),
                    onPressed: () {
                      Navigator.pop(context, {
                        'latitude': location['lat'],
                        'longitude': location['lng'],
                        'address': '${location['name']}, Tunisie',
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Ou entrer une adresse personnalisée:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  hintText: 'Ex: Avenue Habib Bourguiba, Tunis',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: '36.8065',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _lngController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: '10.1815',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_addressController.text.isNotEmpty) {
              final lat = double.tryParse(_latController.text) ?? 36.8065;
              final lng = double.tryParse(_lngController.text) ?? 10.1815;
              Navigator.pop(context, {
                'latitude': lat,
                'longitude': lng,
                'address': _addressController.text,
              });
            }
          },
          child: const Text('Confirmer'),
        ),
      ],
    );
  }
}
