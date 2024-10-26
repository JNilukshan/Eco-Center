import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:center/common/color_extrnsion.dart';

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
        setState(() {
          drivers = json.decode(response.body);
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
                return Padding(
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
                            radius: 40,
                            backgroundImage: NetworkImage(
                              driver['photoUrl'] ?? 'default_image_url',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driver['name'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Vehicle: ${driver['vehicleType']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: TColor.secondaryText,
                                  ),
                                ),
                                Text(
                                  'Phone: ${driver['phone']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: TColor.secondaryText,
                                  ),
                                ),
                                Text(
                                  'Address: ${driver['address']}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: TColor.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
