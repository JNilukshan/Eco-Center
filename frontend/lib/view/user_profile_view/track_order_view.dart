import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/home/TrackOrderLocationView.dart';
import 'package:flutter/material.dart';

class TrackOrderView extends StatelessWidget {
  final String userId;
  final String role;

  const TrackOrderView({
    super.key,
    required this.userId,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Track Order"),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Track your order status here.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigating to TrackOrderLocationView page
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
                backgroundColor: TColor.primary,
              ),
              child: const Text("Track Order"),
            ),
          ],
        ),
      ),
    );
  }
}
