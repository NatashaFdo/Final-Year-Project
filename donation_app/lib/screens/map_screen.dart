import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_place/google_place.dart';

import 'package:donation_app/themes/colors.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? selectedLocation;
  GoogleMapController? mapController;
  LatLng _initialPosition = const LatLng(7.8731, 80.7718);

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    googlePlace = GooglePlace("AIzaSyCGvDk--38-i-4ON5jnI_7t7M-zhg08JS4");
  }

  Future<void> _getCurrentLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        // ignore: curly_braces_in_flow_control_structures
        permission == LocationPermission.deniedForever) return;

    final pos = await Geolocator.getCurrentPosition();
    _initialPosition = LatLng(pos.latitude, pos.longitude);
    mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition));
    setState(() {});
  }

  Future<void> _confirmLocation() async {
    if (selectedLocation == null) return;

    List<Placemark> placemarks = await placemarkFromCoordinates(
      selectedLocation!.latitude,
      selectedLocation!.longitude,
    );

    final placemark = placemarks.first;
    String address =
        "${placemark.street}, ${placemark.locality}, ${placemark.country}";

    // ignore: use_build_context_synchronously
    Navigator.pop(context, {
      'address': address,
      'latitude': selectedLocation!.latitude,
      'longitude': selectedLocation!.longitude,
    });
  }

  void _autoCompleteSearch(String value) async {
    if (value.isEmpty) {
      setState(() => predictions = []);
      return;
    }

    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      setState(() {
        predictions = result.predictions!;
      });
    }
  }

  void _selectPrediction(AutocompletePrediction prediction) async {
    final details = await googlePlace.details.get(prediction.placeId!);
    if (details != null && details.result != null) {
      final location = details.result!.geometry!.location!;
      final latLng = LatLng(location.lat!, location.lng!);

      if (!_isWithinSriLanka(latLng)) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Please select a location within Sri Lanka.")),
        );
        return;
      }

      setState(() {
        selectedLocation = latLng;
        predictions = [];
        searchController.text = details.result!.name!;
      });

      mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
    }
  }

  bool _isWithinSriLanka(LatLng position) {
    const double minLat = 5.9;
    const double maxLat = 9.9;
    const double minLng = 79.5;
    const double maxLng = 82.0;

    return position.latitude >= minLat &&
        position.latitude <= maxLat &&
        position.longitude >= minLng &&
        position.longitude <= maxLng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text("Select a Location"),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 14,
            ),
            onTap: (LatLng latLng) {
              if (!_isWithinSriLanka(latLng)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text("Please select a location within Sri Lanka.")),
                );
                return;
              }

              setState(() {
                selectedLocation = latLng;
              });
            },
            markers: selectedLocation == null
                ? {}
                : {
                    Marker(
                      markerId: const MarkerId("selected"),
                      position: selectedLocation!,
                    )
                  },
            onMapCreated: (controller) {
              mapController = controller;
            },
          ),

          // Search Bar UI
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: "Search location",
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(15),
                    ),
                    onChanged: _autoCompleteSearch,
                  ),
                ),
                if (predictions.isNotEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: predictions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(predictions[index].description ?? ''),
                          onTap: () => _selectPrediction(predictions[index]),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Confirm Button
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: _confirmLocation,
              child: const Text("Confirm Location"),
            ),
          ),
        ],
      ),
    );
  }
}
