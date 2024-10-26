import 'package:center/view/home/TrackOrderLocationView.dart';
import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart'; // Assuming you have this utility for colors
 // Import the new Track Order Location screen

class DTruNotificationViewDetailsView extends StatelessWidget {
  final String title;
  final String description;

  const DTruNotificationViewDetailsView({super.key, required this.title, required this.description});

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
                    // Navigate to Track Order Location mock interface when confirmed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TrackOrderLocationView(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary, // Use primary color for the button
                  ),
                  child: const Text("Confirm"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cancel button action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Use grey for the cancel button
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
