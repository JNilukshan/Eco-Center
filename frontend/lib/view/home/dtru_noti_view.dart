import 'package:center/view/home/TrackOrderLocationView.dart';
import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart';

class DTruNotificationViewDetailsView extends StatelessWidget {
  final String title;
  final String description;
  final String userId; // Add userId parameter to pass to TrackOrderLocationView
  final String role; // Add role parameter

  const DTruNotificationViewDetailsView({
    super.key,
    required this.title,
    required this.description,
    required this.userId,
    required this.role, // Initialize role
  });

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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Track Order Location interface with userId and role
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackOrderLocationView(
                          userId: userId,
                          role: role, 
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        TColor.primary, // Use primary color for the button
                  ),
                  child: const Text("Confirm"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cancel button action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.grey, // Use grey for the cancel button
                  ),
                  child: const Text("Cancel"),
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
