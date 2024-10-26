import 'package:center/common/color_extrnsion.dart';
import 'package:flutter/material.dart';

class Dropodown extends StatelessWidget {
  final String title;
  final String placeholder;
  final List<String> valueList; // Specify that the list contains Strings
  final Function(String?) didChange; // Change to String? for null safety
  final String? selectedValue;

  const Dropodown({
    super.key,
    required this.title,
    required this.placeholder,
    required this.valueList,
    required this.didChange,
    this.selectedValue, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: TColor.secondaryText,
            fontSize: 16, // Small text remains readable on iPhone
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          height: 55,
          child: DropdownButton<String>(
            value: selectedValue, // Use the selectedValue passed from the constructor
            onChanged: didChange, // Call the provided callback
            icon: Icon(
              Icons.expand_more, // Correct usage of Icons
              color: TColor.textTittle,
            ),
            hint: Text(
              placeholder, // Use the placeholder parameter
              style: TextStyle(
                color: TColor.placeholder,
                fontSize: 16, // Small text remains readable on iPhone
                fontWeight: FontWeight.w600,
              ),
            ),
            isExpanded: true,
            items: valueList.map((String zone) {
              return DropdownMenuItem<String>(
                value: zone,
                child: Text(
                  zone, // Show the zone name here
                  style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 16, // Small text remains readable on iPhone
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(), // Convert Iterable to List
          ),
        ),
        Container(
          width: double.maxFinite,
          height: 1,
          color: const Color(0xffE2E2E2),
        ),
      ],
    );
  }
}
