import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:center/view/home/dtru_noti_home.dart';

class TrackOrderLocationView extends StatefulWidget {
  const TrackOrderLocationView({super.key});

  @override
  State<TrackOrderLocationView> createState() => _TrackOrderLocationViewState();
}

class _TrackOrderLocationViewState extends State<TrackOrderLocationView> {
  late GoogleMapController mapController;

  // Default initial position
  final LatLng _initialPosition = const LatLng(37.7749, -122.4194); // San Francisco coordinates
  final Set<Marker> _markers = {}; // To hold markers

  // Initialize Google Maps with a marker
  @override
  void initState() {
    super.initState();
    _markers.add(
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _initialPosition,
        infoWindow: const InfoWindow(title: 'Your Delivery Location'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Order Location'),
        backgroundColor: const Color.fromARGB(255, 17, 48, 28), // Customize the AppBar color
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Google Maps widget
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 14.0,
              ),
              markers: _markers,
            ),
          ),
          const SizedBox(height: 20),

          // Order details or tracking info
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Status: In Transit',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Estimated Delivery Time: 25 minutes',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  'Delivery Location: 123 Main St, Cityville',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                SizedBox(height: 10),
                Text(
                  'Driver Name: John Doe',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const Spacer(),

          // Buttons for user interaction
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DTruNotificationHome(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 17, 48, 28), // Confirm button color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Track Again',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Simply navigate to the DTruNotificationHome page without arguments
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DTruNotificationHome(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Cancel button color
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
