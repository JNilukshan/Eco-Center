import 'package:center/common_widget/round_button.dart';
import 'package:center/view/login/market_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  @override
  void initState() {
    // TODO implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context); // Size of the device

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Image
          Image.asset(
            "assets/img/welcom_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.fill, // Adjust this as needed (fill, contain, etc.)
          ),

          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title text, scaled for iPhone screen sizer
                    Flexible(
                      child: Text(
                        "Welcome \nto Our \nEcoCenter",
                        textAlign: TextAlign.center, // Center the text
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48, // Adjust size based on iPhone 14 screen
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        "Get your vegetables as fast as possible",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color.fromARGB(255, 180, 167, 167),
                          fontSize: 16, // Small text remains readable on iPhone
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20), // Space between text and button

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: RoundButton(
                    title: "Get Started",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MarketView()),
                      );
                      // Button action
                    },
                  ),
                ),

                const SizedBox(height: 46), // Bottom padding for button
              ],
            ),
          ),
        ],
      ),
    );
  }
}
