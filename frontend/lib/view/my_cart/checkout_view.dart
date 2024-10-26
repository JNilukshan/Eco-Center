import 'package:center/common/color_extrnsion.dart';
import 'package:center/common_widget/checkout_row.dart';
import 'package:center/common_widget/round_button.dart';
import 'package:flutter/material.dart';

class CheckoutView extends StatelessWidget {
  final double totalPrice;

  const CheckoutView({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15.0), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // Reduced corner radius
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Checkout header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Checkout",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Image.asset(
                    "assets/img/close.png",
                    width: 15,
                    height: 15,
                    color: TColor.primaryText,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          const Divider(
            color: Colors.black26,
            height: 1,
          ),

          // Total Cost Display
          CheckoutRow(
            title: "Total Cost",
            value: "Rs. $totalPrice",
            onPressed: () {
              // Total cost details
            },
          ),

          // Place Order button
          RoundButton(
            title: "Place Order",
            onPressed: () {
              // Handle order placement
              // Add your order processing logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order placed for Rs. $totalPrice')),
              );
            },
          ),
          const SizedBox(height: 15,)
        ],
      ),
    );
  }
}
