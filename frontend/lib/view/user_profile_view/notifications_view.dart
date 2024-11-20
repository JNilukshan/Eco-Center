import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'notification_details_view.dart';

class NotificationsView extends StatefulWidget {
  final String userId;

  const NotificationsView({super.key, required this.userId});

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  List<Map<String, dynamic>> notifications = [];
  IO.Socket? socket;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    connectToWebSocket();
  }

  Future<void> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:5000/api/notification/getNotifications/${widget.userId}'),
      );

      if (response.statusCode == 200) {
        setState(() {
          notifications = List<Map<String, dynamic>>.from(
            json.decode(response.body)['notifications'],
          );

          // Sort notifications by date in descending order (latest first)
          notifications.sort((a, b) {
            final dateA = DateTime.parse(a['dateTime']);
            final dateB = DateTime.parse(b['dateTime']);
            return dateB.compareTo(dateA);
          });
        });
      } else {
        _showErrorSnackBar('Failed to load notifications');
      }
    } catch (error) {
      _showErrorSnackBar('An error occurred');
    }
  }

  void connectToWebSocket() {
    socket = IO.io('http://localhost:5000',
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket!.onConnect((_) {
      print('Connected to WebSocket');
    });

    socket!.on('newNotification', (data) {
      setState(() {
        notifications.insert(0, Map<String, dynamic>.from(data));

        // Sort notifications after adding the new one
        notifications.sort((a, b) {
          final dateA = DateTime.parse(a['dateTime']);
          final dateB = DateTime.parse(b['dateTime']);
          return dateB.compareTo(dateA);
        });
      });

      // Show the popup dialog for the new notification
      _showNotificationPopup(Map<String, dynamic>.from(data));
    });

    socket!.onDisconnect((_) => print('Disconnected from WebSocket'));
  }

  void _showNotificationPopup(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(notification['message'] ?? 'New Notification'),
          content: Text(
            notification['dateTime'] != null
                ? formatDate(notification['dateTime'])
                : 'No Date Available',
          ),
          actions: [
            TextButton(
              child: const Text('View Details'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailsView(
                      notification: notification,
                    ),
                  ),
                );
              },
            ),
            TextButton(
              child: const Text('Dismiss'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String formatDate(String dateTimeString) {
    final DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  void dispose() {
    socket?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: TColor.primary,
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
                          color: const Color.fromARGB(255, 103, 102, 102).withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // Shadow position
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(notification['message'] ?? 'No Title'),
                      subtitle: Text(notification['dateTime'] != null
                          ? formatDate(notification['dateTime'])
                          : 'No Date'),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailsView(
                              notification: notification,
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
