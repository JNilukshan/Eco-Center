import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dtru_noti_view.dart';

class DTruNotificationHome extends StatefulWidget {
  final String userId;
  final String role;

  const DTruNotificationHome(
      {super.key, required this.userId, required this.role});

  @override
  _DTruNotificationHomeState createState() => _DTruNotificationHomeState();
}

class _DTruNotificationHomeState extends State<DTruNotificationHome> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();

    // Adding demo data to notifications
    notifications = [
      {
        'orderId': '672a62d45d13dc510ce07173',
        'wholesalerAddress': 'Madampe',
        'wholesalerPhone': '761597773',
        'createdAt': '2024-11-06T10:00:00Z',
        'message': 'New job'
      },
      {
        'orderId': '672a6cce5d13dc510ce07286',
        'wholesalerAddress': 'Adhikarigama, Haguranketha',
        'wholesalerPhone': '78654321',
        'createdAt': '2024-11-06T09:00:00Z',
        'message': 'New job'
      },
    ];
  }

  String formatDate(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false, // Remove the back button
        backgroundColor: const Color.fromARGB(
            255, 8, 45, 18), // Customize your app bar color
      ),
      body: notifications.isEmpty
          ? const Center(child: Text('No notifications available'))
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 103, 102, 102)
                              .withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(notification['message'] ?? 'No Title'),
                      subtitle: Text(notification['Date'] ?? 'No Date'),
                      trailing: Text(
                        formatDate(notification['createdAt'] ?? ''),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DTruNotificationViewDetailsView(
                              notification: notification,
                              userId: widget.userId,
                              role: widget.role,
                            ),
                          ),
                        );

                        // Remove the notification from the list if it was deleted
                        if (result == true) {
                          setState(() {
                            notifications.removeAt(index);
                          });
                        }
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
