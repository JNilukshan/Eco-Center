// import 'package:center/common/color_extrnsion.dart';
// import 'package:center/view/main_tabview/main_tabview.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PaymentScreen extends StatefulWidget {
//   final String wholesellerId;
//   final double totalAmount;
//   final String orderId;

//   const PaymentScreen({
//     super.key,
//     required this.wholesellerId,
//     required this.totalAmount,
//     required this.orderId,
//   });

//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   Map<String, dynamic>? paymentIntentData;

//   Future<void> createPaymentIntent() async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:5000/api/payment/processPayment'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'wholesellerId': widget.wholesellerId,
//           'totalAmount': widget.totalAmount,
//           'orderId': widget.orderId,
//         }),
//       );

//       if (response.statusCode == 200) {
//         paymentIntentData = jsonDecode(response.body);
//         await presentPaymentSheet();
//       } else {
//         throw Exception("Failed to create payment intent");
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment failed: ${e.toString()}')),
//       );
//     }
//   }

//   Future<void> presentPaymentSheet() async {
//     try {
//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentData!['clientSecret'],
//           merchantDisplayName: 'Eco Center',
//         ),
//       );

//       await Stripe.instance.presentPaymentSheet();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment Successful")),
//       );

//       setState(() {
//         paymentIntentData = null;
//       });

//       // Navigate to MainTabView after successful payment
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MainTabView(
//             userId: widget.wholesellerId,
//             role: 'wholeseller', // or pass the actual role if available
//           ),
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Payment Cancelled")));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment'),
//         backgroundColor: TColor.primary,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Choose a Payment Method',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             ListTile(
//               leading: const Icon(Icons.payment),
//               title: const Text('Credit / Debit Card'),
//               onTap: () async {
//                 await createPaymentIntent();
//               },
//             ),
//             const Spacer(),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Total Amount: Rs.${widget.totalAmount.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () async {
//                       await createPaymentIntent();
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: TColor.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     child: const Center(
//                       child: Text(
//                         'Proceed to Pay',
//                         style: TextStyle(fontSize: 18, color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
