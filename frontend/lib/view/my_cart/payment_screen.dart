// payment_method_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentMethodScreen extends StatefulWidget {
  final double totalPrice;

  const PaymentMethodScreen({super.key, required this.totalPrice});

  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  Map<String, dynamic>? paymentIntentData;

  Future<void> createPaymentIntent() async {
    try {
      // Send a request to your backend to create a checkout session
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/payments/create-checkout-session'), // Replace <your_local_ip> with your IP address
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'netTotal': widget.totalPrice}),
      );

      if (response.statusCode == 200) {
        // Parse the JSON response from the backend
        paymentIntentData = jsonDecode(response.body);
        await presentPaymentSheet(); // Display the payment sheet
      } else {
        throw Exception("Failed to create payment intent");
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${e.toString()}')),
      );
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      // Initialize and display the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentData!['id'], // Use session ID from backend
          merchantDisplayName: 'Eco Center',
        ),
      );

      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment Successful")),
      );

      setState(() {
        paymentIntentData = null; // Reset payment intent data after success
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Payment Cancelled")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: const Color.fromARGB(255, 17, 48, 28),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Credit / Debit Card'),
              onTap: () async {
                await createPaymentIntent(); // Initiates the online payment
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price: Rs. ${widget.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await createPaymentIntent(); // Start payment on button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 17, 48, 28),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Proceed to Pay',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
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
