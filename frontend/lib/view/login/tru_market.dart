import 'package:center/common_widget/round_button.dart';
import 'package:center/view/login/loginView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TruMarketView extends StatefulWidget {
  const TruMarketView({super.key});

  @override
  State<TruMarketView> createState() => _TruMarketViewState();
}

class _TruMarketViewState extends State<TruMarketView> {
  @override
  void initState() {
    //TODO implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Center the content vertically
        children: [
          // Image centered with minimal space between image and buttons
          Image.asset(
            "assets/img/home.png",  // Ensure this path is correct
            width: media.size.width * 0.7,  // Adjust width to fit the center
            height: media.size.height * 0.4, // Adjust height
            fit: BoxFit.contain, // Keeps aspect ratio while making it fit
          ),
          const SizedBox(height: 10), // Minimal space between image and text

          // Title text
          const Text(
            "Select your nearest market",
            textAlign: TextAlign.center, // Center the text
            style: TextStyle(
              color: Colors.black, // Black color for visibility
              fontSize: 28, // Adjust font size
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10), // Minimal space between text and buttons

          // Dambulla Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RoundButton(
              title: "Dambulla",
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const LoginView(userId: '',)));
              },
            ),
          ),

          const SizedBox(height: 10), // Reduced space between buttons

          // Meegoda Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: RoundButton(
              title: "Meegoda",
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => const LoginView(userId: '',)));
              },
            ),
          ),

          const SizedBox(height: 20), // Minimal bottom padding
        ],
      ),
    );
  }
}
