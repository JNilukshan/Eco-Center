import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/my_cart/my_cart_view.dart';
import 'package:flutter/material.dart';

class ProductCell extends StatelessWidget {
  final Map<String, dynamic> vegetable;
  final String userId;
  final String role;
  final Function(Map<String, dynamic>) addToCart;

  const ProductCell({
    super.key,
    required this.vegetable,
    required this.userId,
    required this.role,
    required this.addToCart,
  });

  @override
  Widget build(BuildContext context) {
    final bool isOutOfStock = (vegetable['quantity'] ?? 0) <= 0;

    return InkWell(
      onTap: () {
        // Optional: Implement onPressed action if you want to do something on cell tap
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: TColor.placeholder.withOpacity(0.5),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  vegetable["image"] ?? "https://via.placeholder.com/100",
                  width: 100,
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.image, size: 80);
                  },
                ),
              ],
            ),
            const Spacer(),
            Text(
              vegetable["name"] ?? "Unknown Vegetable",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Available Stock: ${vegetable["quantity"] ?? 'N/A'} kg",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "Unit Price: Rs. ${vegetable["unitprice"] ?? '0'}",
              style: TextStyle(
                color: TColor.secondaryText,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Rs. ${vegetable["unitprice"] ?? '0'}",
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InkWell(
                  onTap: isOutOfStock
                      ? null
                      : () {
                          // Add item to cart using the callback
                          addToCart({
                            "itemId": vegetable["id"] ?? "",
                            "name": vegetable["name"] ?? "Unnamed Item",
                            "quantity": 1,
                            "unitprice": vegetable["unitprice"] ?? 0,
                          });

                          // Navigate to MyCartView
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyCartView(
                                userId: userId,
                                role: role,
                                updateStock: (updatedCart) {},
                              ),
                            ),
                          );
                        },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: isOutOfStock ? Colors.grey : TColor.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      "assets/img/add.png",
                      width: 15,
                      height: 15,
                    ),
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
