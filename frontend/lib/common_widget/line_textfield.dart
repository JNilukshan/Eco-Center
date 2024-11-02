import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';

class LineTextfield extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String placeholder;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? right;
  final String? Function(String?)? validator;
  final TextStyle? titleTextStyle;
  final InputDecoration? decoration;

  const LineTextfield({
    super.key,
    required this.controller,
    required this.title,
    required this.placeholder,
    this.right,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.titleTextStyle,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: titleTextStyle ?? const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          decoration: decoration?.copyWith(
            hintText: placeholder,
            suffixIcon: right,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffE2E2E2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
          ) ?? InputDecoration(
            hintText: placeholder,
            suffixIcon: right,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xffE2E2E2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.green),
            ),
            hintStyle: TextStyle(
              color: TColor.placeholder,
              fontSize: 17,
            ),
          ),
          validator: validator,
        ),
        Container(
          width: double.infinity,
          height: 1,
          color: const Color(0xffE2E2E2),
        ),
      ],
    );
  }
}
