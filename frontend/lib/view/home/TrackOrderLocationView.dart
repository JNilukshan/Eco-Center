import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:center/view/home/dtru_noti_home.dart';
import 'package:center/view/main_tabview/main_tabview.dart';
import 'package:center/view/main_tabview/dtru_main_tab.dart';

class TrackOrderLocationView extends StatefulWidget {
  final String userId;
  final String role;

  const TrackOrderLocationView({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  State<TrackOrderLocationView> createState() => _TrackOrderLocationViewState();
}

class _TrackOrderLocationViewState extends State<TrackOrderLocationView> {
  late GoogleMapController mapController;

  // Default initial position
  final LatLng _initialPosition =
      const LatLng(37.7749, -122.4194); // San Francisco coordinates
  final Set<Marker> _markers = {}; // To hold markers

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
        backgroundColor: const Color.fromARGB(255, 17, 48, 28),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate based on user role
            if (widget.role == 'driver') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DTruMainTabView(
                    userId: widget.userId,
                    role: widget.role,
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainTabView(
                    userId: widget.userId,
                    role: widget.role,
                  ),
                ),
              );
            }
          },
        ),
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
                        builder: (context) => DTruNotificationHome(
                          userId: widget.userId,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 17, 48, 28),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: const Text(
                    'Track Again',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DTruNotificationHome(
                          userId: widget.userId,
                          role: widget.role,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
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
