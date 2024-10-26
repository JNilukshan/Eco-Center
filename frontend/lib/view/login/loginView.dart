


import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:center/common/color_extrnsion.dart';
import 'package:center/common_widget/line_textfield.dart';
import 'package:center/common_widget/round_button.dart';
import 'package:center/view/login/forgotpassword_emailview.dart';
import 'package:center/view/main_tabview/main_tabview.dart';
import 'package:center/view/main_tabview/dtru_main_tab.dart';
import 'package:flutter/material.dart';
import 'package:center/view/login/signUpView.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key, required String userId});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool isShow = false; 

  // Combine function for both wholeseller and truck driver login
  Future<void> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/auth/login'), // Replace with your server URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String userId = data['userId'];
        final String role = data['role'];

        // Check the user's role to navigate to the appropriate dashboard
        if (role == 'wholeseller') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MainTabView(userId: userId, role: 'wholeseller',), 
            ),
          );
        } else if (role == 'driver') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DTruMainTabView(userId: userId, role: 'driver'), 
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unknown user role')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        Container(
          color: Colors.white,
        ),
        Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Image.asset(
                "assets/img/back.png",
                width: 20,
                height: 20,
              ),
            ),
          ),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/img/logoe.png",
                          width: 200,
                          height: 150,
                        ),
                      ],
                    ),
                    SizedBox(height: media.width * 0.05),
                    Text(
                      "Login",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: media.width * 0.03),
                    Text(
                      "Enter your email and password",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: media.width * 0.1),
                    LineTextfield(
                      controller: txtEmail,
                      title: "Email",
                      placeholder: "Enter your email address",
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                    SizedBox(height: media.width * 0.07),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Navigate to Forgot Password Email View
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordEmailView(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: media.width * 0.07),
                    RoundButton(
                      title: "Log In",
                      onPressed: () {
                        // Call login function for both wholeseller and truckdriver
                        loginUser(
                          txtEmail.text,
                          txtPassword.text,
                        );
                      },
                    ),
                    SizedBox(height: media.width * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Redirect to Signup View
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return SizedBox(
                                  height: 200,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        title: const Text("Sign Up as Wholeseller"),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpView(role: 'wholeseller',),
                                            ),
                                          );
                                        },
                                      ),
                                      ListTile(
                                        title: const Text("Sign Up as Truck Driver"),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const SignUpView(role: 'driver',),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                " SignUp",
                                style: TextStyle(
                                  color: TColor.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
