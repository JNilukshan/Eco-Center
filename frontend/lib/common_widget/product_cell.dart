import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/my_cart/my_cart_view.dart';
import 'package:flutter/material.dart';

class ProductCell extends StatelessWidget {
  final Map pObj;
  final VoidCallback onPressed;
  final VoidCallback onCart;

  const ProductCell({
    super.key,
    required this.pObj,
    required this.onPressed,
    required this.onCart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
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
                Image.asset(
                  pObj["icon"],
                  width: 100,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ],
            ),
            const Spacer(),
            Text(
              pObj["name"],
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "Available Stock : ",
              style: TextStyle(
                color: TColor.primaryText,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              " ${pObj["qty"]}${pObj["unit"]}",
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
                  pObj["price"],
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                // Add Navigator to InkWell here
                InkWell(
                  onTap: () {
                    // Example navigation to Cart screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyCartView(cartItems: [],), // Assuming CartPage exists
                      ),
                    );
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: TColor.primary,
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
