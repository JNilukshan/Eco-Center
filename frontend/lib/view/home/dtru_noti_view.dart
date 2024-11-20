import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/home/TrackOrderLocationView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DTruNotificationViewDetailsView extends StatelessWidget {
  final Map<String, dynamic> notification;
  final String userId;
  final String role;

  const DTruNotificationViewDetailsView({
    super.key,
    required this.notification,
    required this.userId,
    required this.role,
  });

  String formatDate(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Details"),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${notification["orderId"] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Wholesaler Address: ${notification["wholesalerAddress"] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              "Wholesaler Phone: ${notification["wholesalerPhone"] ?? 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 10),
            Text(
              "Date: ${formatDate(notification["createdAt"])}",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TrackOrderLocationView(
                        userId: userId,
                        role: role,
                      ),
                    ),
                  );
                },
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
