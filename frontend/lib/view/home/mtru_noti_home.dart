import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/home/dtru_noti_view.dart';
import 'package:flutter/material.dart';
 // Import the notification details view

class MTruNotificationHome extends StatefulWidget {
  const MTruNotificationHome({super.key});

  @override
  State<MTruNotificationHome> createState() => _MTruNotificationHomeState();
}

class _MTruNotificationHomeState extends State<MTruNotificationHome> {
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
                          builder: (context) => const DTruNotificationViewDetailsView(
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
                          builder: (context) => const DTruNotificationViewDetailsView(
                            title: "Promo Code",
                            description: "Use code PICK10 to get 10% off your next ride.",
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
                          builder: (context) => const DTruNotificationViewDetailsView(
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
