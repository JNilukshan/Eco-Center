import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';

class CartItemRow extends StatefulWidget {
  final Map pObj; // The product data map

  const CartItemRow({super.key, required this.pObj});

  @override
  State<CartItemRow> createState() => _CartItemRowState();
}

class _CartItemRowState extends State<CartItemRow> {
  int _quantity = 1; // Initial quantity

  // Function to increment the quantity
  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  // Function to decrement the quantity
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Function to calculate the total price based on the unit price and quantity
  double _calculateTotalPrice() {
    double unitPrice = double.parse(widget.pObj['price'].toString().replaceAll('Rs.', '').trim());
    return _quantity * unitPrice; // Total price = unit price * quantity
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        height: 125,
        padding: const EdgeInsets.symmetric(vertical: 15),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main row: Image, name, close button
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image
                Image.asset(
                  widget.pObj["icon"],
                  width: 100,
                  height: 80,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          // Product name
                          Expanded(
                            child: Text(
                              widget.pObj["name"],
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          // Close button
                          InkWell(
                            onTap: () {
                              // Handle item removal logic here
                            },
                            child: Image.asset(
                              "assets/img/close.png",
                              width: 15,
                              height: 15,
                              color: TColor.secondaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      // Product unit
                      Text(
                        "${widget.pObj["unit"]}",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          // Subtract button
                          InkWell(
                            onTap: _decrementQuantity,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: TColor.placeholder.withOpacity(0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/img/sub_green.png",
                                width: 15,
                                height: 15,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Quantity display
                          Container(
                            width: 35,
                            height: 35,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: TColor.placeholder.withOpacity(0.5),
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _quantity.toString(), // Updated quantity displayed
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          // Add button
                          InkWell(
                            onTap: _incrementQuantity,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: TColor.placeholder.withOpacity(0.5),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              alignment: Alignment.center,
                              child: Image.asset(
                                "assets/img/add_green.png",
                                width: 15,
                                height: 15,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Total price display (quantity * unit price)
                          Text(
                            "Rs. ${_calculateTotalPrice().toStringAsFixed(2)}", // Updated total price
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
