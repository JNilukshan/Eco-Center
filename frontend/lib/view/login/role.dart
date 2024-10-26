// import 'package:center/common/color_extrnsion.dart';
// import 'package:center/common_widget/round_button.dart';
// import 'package:center/view/login/market_view.dart';
// import 'package:center/view/login/tru_market.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class RoleView extends StatefulWidget {
//   const RoleView({super.key});

//   @override
//   State<RoleView> createState() => _RoleViewState();
// }

// class _RoleViewState extends State<RoleView> {
//   @override
//   void initState() {
//     super.initState();
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
//   }




//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.sizeOf(context); // Size of the device

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Image at the top
//           Padding(
//             padding: const EdgeInsets.only(top: 50.0),
//             child: Image.asset(
//               "assets/img/home1.png",
//               width: media.width * 0.7,  // Adjust width to fit the center
//               height: media.height * 0.4, // Adjust height to control size
//               fit: BoxFit.contain, // Keeps aspect ratio while making it fit
//             ),
//           ),
          
//           const SizedBox(height: 20), // Add spacing between the image and the title
          
//           // Title text
//           Text(
//             "Select Your Role",
//             textAlign: TextAlign.center, // Center the text
//             style: TextStyle(
//               color: TColor.primaryText, // Adjust the text color
//               fontSize: 24, // Adjust font size to fit better
//               fontWeight: FontWeight.w600,
//             ),
//           ),

//           const SizedBox(height: 20), // Minimal spacing between title and first button

//           // Add buttons with minimal space between the image and the buttons
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20.0),
//             child: Column(
//               children: [
//                 // WholeSaler Button
//                 RoundButton(
//                   title: "WholeSaler",
//                   onPressed: () {
//                     Navigator.push(
//                         context, MaterialPageRoute(builder: (context) => const MarketView()));
//                   },
//                 ),

//                 const SizedBox(height: 15), // Spacing between buttons

//                 // Truck Driver Button
//                 RoundButton(
//                   title: "Truck Driver",
//                   onPressed: () {
//                     Navigator.push(
//                         context, MaterialPageRoute(builder: (context) => const TruMarketView()));
//                   },
//                 ),

//                 const SizedBox(height: 30), // Add some space below the buttons to look balanced
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
