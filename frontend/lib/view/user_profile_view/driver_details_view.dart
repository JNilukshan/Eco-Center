import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DriverDetailsView extends StatefulWidget {
  final Map<String, dynamic> driver;
  final VoidCallback onAvailabilityChanged;

  const DriverDetailsView({
    super.key,
    required this.driver,
    required this.onAvailabilityChanged,
  });

  @override
  _DriverDetailsViewState createState() => _DriverDetailsViewState();
}

class _DriverDetailsViewState extends State<DriverDetailsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late bool isAvailable;
  final TextEditingController _orderIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isAvailable = widget.driver['isAvailable'] ?? false;
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      lowerBound: 0.9,
      upperBound: 1.0,
    );
    _scaleAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _orderIdController.dispose();
    super.dispose();
  }

  Future<void> _toggleAvailability() async {
    final String driverId = widget.driver['_id'];
    final String orderId = _orderIdController.text.trim();

    if (orderId.isEmpty) {
      _showMessage("Please enter an order ID!");
      return;
    }

    try {
      final response = await http.patch(
        Uri.parse('http://localhost:5000/api/auth/drivers/$driverId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'isAvailable': false, 'orderId': orderId}),
      );

      if (response.statusCode == 200) {
        setState(() => isAvailable = false);
        widget.onAvailabilityChanged();
        _showMessage("Driver hired successfully!");

        await http.post(
          Uri.parse('http://localhost:5000/api/notifications'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'orderId': orderId,
            'wholesellerName': widget.driver['name'],
            'wholesellerAddress': widget.driver['address'],
            'wholesellerPhone': widget.driver['phone'],
            'driverId': driverId,
          }),
        );
        Navigator.pop(context);
      } else {
        _showMessage("Failed to hire driver.");
      }
    } catch (e) {
      _showMessage("Error hiring driver.");
      print('Error updating driver availability: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final driver = widget.driver;

    return Scaffold(
      appBar: AppBar(
        title: Text(driver['name'] ?? 'Driver Profile'),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  driver['photoUrl'] ?? 'https://via.placeholder.com/150',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Driver Information
            _buildProfileSection("Personal Information", [
              _buildInfoRow("Name", driver['name']),
              _buildInfoRow("Phone", driver['phone']),
              _buildInfoRow("Address", driver['address']),
            ]),

            const SizedBox(height: 12),

            _buildProfileSection("Vehicle Information", [
              _buildInfoRow("Vehicle Type", driver['vehicleType']),
              _buildInfoRow("Vehicle Number", driver['vehicalnumber']),
              _buildInfoRow(
                  "Availability", isAvailable ? 'Available' : 'Unavailable',
                  color: isAvailable ? Colors.green : Colors.red),
            ]),

            const SizedBox(height: 12),

            // Order ID Text Field
            TextField(
              controller: _orderIdController,
              decoration: const InputDecoration(
                labelText: "Enter Order ID",
                border: OutlineInputBorder(),
              ),
            ),

            const Spacer(),

            // Hire Button with Animation
            Center(
              child: GestureDetector(
                onTapDown: (_) => _animationController.reverse(),
                onTapUp: (_) {
                  _animationController.forward();
                  if (isAvailable) {
                    _toggleAvailability();
                  } else {
                    _showMessage("Driver is already unavailable.");
                  }
                },
                onTapCancel: () => _animationController.forward(),
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 110,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      color: TColor.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 3,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Hire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Divider(),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value,
      {Color color = Colors.black54}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(fontSize: 16, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
