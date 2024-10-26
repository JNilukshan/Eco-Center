import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final Color? bgColor;
  final VoidCallback onPressed;

  const RoundButton({
    super.key,
    required this.title,
    this.bgColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: 60,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      minWidth: double.maxFinite, // Full width button
      elevation: 0.1,
      color: bgColor ?? TColor.primary, // Use bgColor if provided, otherwise default to primary color
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class RoundIconButton extends StatelessWidget {
  final String title;
  final String icon;
  final Color bgColor;
  final VoidCallback onPressed;

  const RoundIconButton({
    super.key,
    required this.title,
    required this.icon,
    required this.bgColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      onPressed: onPressed,
      height: 60,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19)),
      minWidth: double.maxFinite, // Full width button
      elevation: 0.1,
      color: bgColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to the left and right
        children: [
          // Icon on the left
          Row(
            children: [
              Image.asset(
                icon,
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          
          // Circular white icon on the right side
          Container(
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
            child: Icon(
              Icons.arrow_forward_ios,
              color: TColor.primary, // Color for arrow
              size: 16, // Adjust icon size as needed
            ),
          ),
        ],
      ),
    );
  }
}
