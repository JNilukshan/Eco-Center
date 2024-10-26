import 'package:flutter/material.dart';

class PaymentMethodScreen extends StatelessWidget {
  final double totalPrice; // Accept the total price as a parameter

  const PaymentMethodScreen({super.key, required this.totalPrice});

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
              leading: const Icon(Icons.credit_card),
              title: const Text('Cash Payment'),
              onTap: () {
                // Handle cash payment
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Bank Transfer'),
              onTap: () {
                // Handle bank transfer
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Credit / Debit Card'),
              onTap: () {
                // Handle card payment
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price: Rs. ${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Proceed to final payment action
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
