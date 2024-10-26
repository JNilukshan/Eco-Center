import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';
import 'notification_details_view.dart'; // Import the notification details view

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  bool notificationsAccepted = true; // Default to accepting notifications

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Notification toggle
            const SizedBox(height: 20),

            // Divider to separate the notification examples
            const Divider(),
            const SizedBox(height: 10),

            // Example Notifications
            Expanded(
              child: ListView(
                children: [
                  ExampleNotification(
                    title: "Ride Arrived",
                    description: "Your ride is waiting at your location. Please meet the driver.",
                    icon: Icons.directions_car,
                    notificationTime: "Just Now",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationDetailsView(
                            title: "Ride Arrived",
                            description: "Your ride has arrived and is waiting at your location.",
                          ),
                        ),
                      );
                    },
                  ),
                  ExampleNotification(
                    title: "Promo: 10% off your next ride!",
                    description: "Use code PICK10 to get 10% off your next ride. Expires in 2 days.",
                    icon: Icons.local_offer,
                    notificationTime: "1 hour ago",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationDetailsView(
                            title: "Promo Code",
                            description: "Use code PICK10 to get 10% off your next ride.",
                          ),
                        ),
                      );
                    },
                  ),
                  ExampleNotification(
                    title: "Ride Completed",
                    description: "Your ride to Colombo is complete. Rate your driver.",
                    icon: Icons.star_rate,
                    notificationTime: "2 hours ago",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationDetailsView(
                            title: "Ride Completed",
                            description: "Your ride to Colombo is complete. Please rate your driver.",
                          ),
                        ),
                      );
                    },
                  ),
                  ExampleNotification(
                    title: "Fare Update",
                    description: "Your fare for the recent trip has been updated. Check the details.",
                    icon: Icons.attach_money,
                    notificationTime: "Yesterday",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationDetailsView(
                            title: "Fare Update",
                            description: "Your fare for the recent trip has been updated.",
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying individual notifications
class ExampleNotification extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String notificationTime;
  final VoidCallback onTap;

  const ExampleNotification({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.notificationTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: TColor.primary.withOpacity(0.2),
          child: Icon(icon, color: TColor.primary),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Text(
          notificationTime,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: onTap, // Navigate to notification details on tap
      ),
    );
  }
}
