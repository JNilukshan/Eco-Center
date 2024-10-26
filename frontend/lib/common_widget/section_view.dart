import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';

class SectionView extends StatelessWidget {

  final String title;
  final bool isShowSeeAllButton;
  final VoidCallback onPressed;
  final EdgeInsets? padding;


  const SectionView({super.key,
   required this.title, 
   required this.isShowSeeAllButton, 
   required this.onPressed, 
   this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
             style: TextStyle(
              color: TColor.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              ),
            ),
          
        ],
      ),
    );
  }
}