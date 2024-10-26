import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart'; // Assuming you have this utility for colors

class NotificationDetailsView extends StatelessWidget {
  final String title;
  final String description;

  const NotificationDetailsView({super.key, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Confirm button action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary, // Use primary color for the button
                  ),
                  child: const Text("Delete"),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
