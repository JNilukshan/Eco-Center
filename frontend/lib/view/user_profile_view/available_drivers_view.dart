import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:center/common/color_extrnsion.dart';
import 'driver_details_view.dart';

class AvailableDriversView extends StatefulWidget {
  const AvailableDriversView({super.key});

  @override
  _AvailableDriversViewState createState() => _AvailableDriversViewState();
}

class _AvailableDriversViewState extends State<AvailableDriversView> {
  List<dynamic> drivers = [];

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  Future<void> fetchDrivers() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/auth/drivers'));
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print(responseData); // Debug: log API response data
        setState(() {
          drivers = responseData;
        });
      } else {
        print('Failed to load drivers: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading drivers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Drivers"),
        backgroundColor: TColor.primary,
      ),
      body: drivers.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: drivers.length,
              itemBuilder: (context, index) {
                final driver = drivers[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverDetailsView(
                          driver: driver,
                          onAvailabilityChanged:
                              fetchDrivers, // Refresh on change
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 35,
                              backgroundImage: NetworkImage(
                                driver['photoUrl'] ??
                                    'https://via.placeholder.com/150', // Placeholder if no image
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driver['name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    driver['address'] ??
                                        'Address not available',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    driver['isAvailable'] == true
                                        ? 'Available'
                                        : 'Unavailable',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: driver['isAvailable'] == true
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
