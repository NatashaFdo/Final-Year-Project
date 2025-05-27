import 'package:flutter/material.dart';
import 'package:donation_app/screens/map_screen.dart';

class LocationPicker extends StatefulWidget {
  final Function(String address, double lat, double lng) onLocationSelected;

  const LocationPicker({super.key, required this.onLocationSelected});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  String? selectedAddress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 45,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.location_on_outlined, size: 20),
            label: Text(
              selectedAddress == null ? "Add Location" : "Change Location",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MapPickerScreen()),
              );

              if (result != null && result is Map<String, dynamic>) {
                final address = result['address'];
                final lat = result['latitude'];
                final lng = result['longitude'];

                setState(() {
                  selectedAddress = address;
                });

                widget.onLocationSelected(address, lat, lng);
              }
            },
          ),
        ),

        const SizedBox(height: 10),

        // Preview card
        if (selectedAddress != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: Row(
              children: [
                const Icon(Icons.place, color: Colors.green, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedAddress!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
