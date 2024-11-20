import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class NotificationDetailsView extends StatelessWidget {
  final Map<String, dynamic> notification;

  const NotificationDetailsView({super.key, required this.notification});

  String formatDate(String dateTimeString) {
    try {
      final DateTime dateTime = DateTime.parse(dateTimeString);
      return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
    } catch (e) {
      return 'Invalid Date';
    }
  }

  Future<void> deleteNotification(BuildContext context) async {
    final String notificationId = notification['_id'];
    final String userId = notification['userId'];

    try {
      final response = await http.delete(
        Uri.parse(
          'http://localhost:5000/api/notification/deleteNotification/$userId/$notificationId',
        ),
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pop(true); // Return true to indicate deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete notification')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting notification: $error')),
      );
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
              "Message: ${notification["message"] ?? 'No Message'}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Amount: ${notification["amount"] != null ? 'Rs.${notification["amount"]}' : 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Order ID: ${notification["orderId"] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (notification["orderId"] != null) {
                      Clipboard.setData(
                          ClipboardData(text: notification["orderId"]));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Order ID copied to clipboard")),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4.0),
                    child: Icon(
                      Icons.copy,
                      size: 18, // Smaller icon size
                      color: Colors.grey[600], // Adjust color if needed
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Date: ${notification["dateTime"] != null ? formatDate(notification["dateTime"]) : 'N/A'}",
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.delete),
                label: const Text('Delete Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 12, 55, 14),
                ),
                onPressed: () => deleteNotification(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
