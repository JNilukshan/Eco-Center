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
  final _formKey = GlobalKey<FormState>();
  TextEditingController txtUsername = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtLicenseExpiry = TextEditingController();

  String? selectedVehicleType;
  final List<String> vehicleTypes = [
    'Car',
    'Truck',
    'Van',
    'Motorcycle',
    'Bus'
  ];
  bool isShowPassword = false;
  bool isShowConfirmPassword = false;

  Future<void> signupUser(
      String name, String email, String password, String address, String phone,
      {String? vehicleType, String? vehicalnumber}) async {
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
          'phone': phone,
          'vehicleType': vehicleType ?? '',
          'vehicalnumber': vehicalnumber ?? '',
          'role': widget.role,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final String userId = data['userId'];

        // Display success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Registration successful!"),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to the appropriate dashboard based on role
        if (widget.role == 'wholeseller') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainTabView(
                userId: userId,
                role: 'wholeseller',
                updateStock: false,
              ),
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
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Registration failed')),
        );
      }
    } catch (e) {
      print('Error occurred during signup: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
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
              child: Form(
                key: _formKey,
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: media.width * 0.06),
                          LineTextfield(
                            controller: txtUsername,
                            title: "Username",
                            placeholder: "Enter your username",
                            keyboardType: TextInputType.text,
                            obscureText: false,
                            validator: (value) => null,
                            titleTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: media.width * 0.04),
                          LineTextfield(
                            controller: txtEmail,
                            title: "Email",
                            placeholder: "Enter your email address",
                            keyboardType: TextInputType.emailAddress,
                            obscureText: false,
                            validator: (value) => null,
                            titleTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: media.width * 0.04),
                          LineTextfield(
                            controller: txtAddress,
                            title: "Address",
                            placeholder: "Enter your address",
                            keyboardType: TextInputType.streetAddress,
                            obscureText: false,
                            validator: (value) => null,
                            titleTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: media.width * 0.04),
                          LineTextfield(
                            controller: txtPhone,
                            title: "Phone Number",
                            placeholder: "Enter your phone number",
                            keyboardType: TextInputType.phone,
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                                return 'Phone number should contain 9 digits after +94';
                              }
                              return null;
                            },
                            titleTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                            decoration: const InputDecoration(
                              prefixText: '+94 ',
                            ),
                          ),
                          if (widget.role == 'driver') ...[
                            SizedBox(height: media.width * 0.04),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "Vehicle Type",
                                labelStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                            ),
                            SizedBox(height: media.width * 0.04),
                            LineTextfield(
                              controller: txtLicenseExpiry,
                              title: "Vehicle number",
                              placeholder: "Enter your vehicle number",
                              keyboardType: TextInputType.text,
                              obscureText: false,
                              validator: (value) => null,
                              titleTextStyle:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                          SizedBox(height: media.width * 0.04),
                          LineTextfield(
                            controller: txtPassword,
                            title: "Password",
                            placeholder: "Enter your Password",
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !isShowPassword,
                            right: IconButton(
                              icon: Icon(
                                isShowPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isShowPassword = !isShowPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 7) {
                                return 'Password must be at least 7 characters long';
                              }
                              if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                                  .hasMatch(value)) {
                                return 'Password must contain at least one symbol';
                              }
                              return null;
                            },
                            titleTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: media.width * 0.04),
                          LineTextfield(
                            controller: confirmPasswordController,
                            title: "Confirm Password",
                            placeholder: "Re-enter your password",
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: !isShowConfirmPassword,
                            right: IconButton(
                              icon: Icon(
                                isShowConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isShowConfirmPassword =
                                      !isShowConfirmPassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != txtPassword.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                            titleTextStyle:
                                const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: media.width * 0.05),
                    RoundButton(
                      title: "Sign Up",
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          signupUser(
                            txtUsername.text,
                            txtEmail.text,
                            txtPassword.text,
                            txtAddress.text,
                            txtPhone.text,
                            vehicleType: widget.role == 'driver'
                                ? selectedVehicleType
                                : null,
                            vehicalnumber: widget.role == 'driver'
                                ? txtLicenseExpiry.text
                                : null,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
