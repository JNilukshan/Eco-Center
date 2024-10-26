import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:center/common/color_extrnsion.dart';
import 'package:center/common_widget/line_textfield.dart';
import 'package:center/common_widget/round_button.dart';
import 'package:center/view/main_tabview/main_tabview.dart';
import 'package:center/view/main_tabview/dtru_main_tab.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  final String role; // 'wholeseller' or 'driver'

  const SignUpView({super.key, required this.role});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPhone =
      TextEditingController(); // New phone number field

  // Specific to truck drivers
  TextEditingController txtLicenseExpiry = TextEditingController();

  String? selectedVehicleType;
  final List<String> vehicleTypes = [
    'Car',
    'Truck',
    'Van',
    'Motorcycle',
    'Bus'
  ];
  bool isShow = false;

  Future<void> signupUser(
      String name, String email, String password, String address, String phone,
      {String? vehicleType, String? vehicalnumber}) async {
    // Check if phone number is exactly 10 digits
    if (phone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Phone number is incorrect. It should be 10 digits.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8'
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'address': address,
          'phone': phone, // Include phone number
          'vehicleType': vehicleType ?? '',
          'vehicalnumber': vehicalnumber ?? '',
          'role': widget.role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String userId = data['userId'];

        if (widget.role == 'wholeseller') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  MainTabView(userId: userId, role: 'wholeseller'),
            ),
          );
        } else if (widget.role == 'driver') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  DTruMainTabView(userId: userId, role: 'driver'),
            ),
          );
        }
      } else {
        print('Failed to signup');
        print(response.body);
      }
    } catch (e) {
      print('Error occurred during signup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        Container(color: Colors.white),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset("assets/img/back.png", width: 20, height: 20),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset("assets/img/logoe.png",
                          width: 200, height: 150),
                    ],
                  ),
                  SizedBox(height: media.width * 0.02),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: media.width * 0.01),
                  Text(
                    "Enter your credentials to continue",
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: media.width * 0.06),
                  LineTextfield(
                    controller: txtUsername,
                    title: "Username",
                    placeholder: "Enter your username",
                    keyboardType: TextInputType.text,
                    obscureText: false,
                  ),
                  SizedBox(height: media.width * 0.04),
                  LineTextfield(
                    controller: txtEmail,
                    title: "Email",
                    placeholder: "Enter your email address",
                    keyboardType: TextInputType.emailAddress,
                    obscureText: false,
                  ),
                  SizedBox(height: media.width * 0.04),
                  LineTextfield(
                    controller: txtAddress,
                    title: "Address",
                    placeholder: "Enter your address",
                    keyboardType: TextInputType.streetAddress,
                    obscureText: false,
                  ),
                  SizedBox(height: media.width * 0.04),
                  LineTextfield(
                    controller: txtPhone, // New phone field
                    title: "Phone Number",
                    placeholder: "Enter your 10-digit phone number",
                    keyboardType: TextInputType.phone,
                    obscureText: false,
                  ),
                  SizedBox(height: media.width * 0.04),
                  if (widget.role == 'driver') ...[
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Vehicle Type",
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5)),
                      ),
                      value: selectedVehicleType,
                      hint: const Text('Select your vehicle type'),
                      items: vehicleTypes.map((String vehicle) {
                        return DropdownMenuItem<String>(
                          value: vehicle,
                          child: Text(vehicle),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedVehicleType = newValue;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a vehicle type' : null,
                    ),
                    SizedBox(height: media.width * 0.04),
                    LineTextfield(
                      controller: txtLicenseExpiry,
                      title: "Vehical number",
                      placeholder: "Enter your vehical number",
                      keyboardType: TextInputType.text,
                      obscureText: false,
                    ),
                    SizedBox(height: media.width * 0.04),
                  ],
                  LineTextfield(
                    controller: txtPassword,
                    title: "Password",
                    placeholder: "Enter your Password",
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: !isShow,
                    right: IconButton(
                      onPressed: () {
                        setState(() {
                          isShow = !isShow;
                        });
                      },
                      icon: Icon(
                        !isShow ? Icons.visibility_off : Icons.visibility,
                        color: TColor.textTittle,
                      ),
                    ),
                  ),
                  SizedBox(height: media.width * 0.05),
                  RoundButton(
                    title: "Sign Up",
                    onPressed: () {
                      signupUser(
                        txtUsername.text,
                        txtEmail.text,
                        txtPassword.text,
                        txtAddress.text,
                        txtPhone.text, // Pass phone number to signup function
                        vehicleType: widget.role == 'driver'
                            ? selectedVehicleType
                            : null,
                        vehicalnumber: widget.role == 'driver'
                            ? txtLicenseExpiry.text
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
