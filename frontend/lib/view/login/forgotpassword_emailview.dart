import 'package:center/view/login/forgotpasswordverificationview.dart';
import 'package:flutter/material.dart';
import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/login/auth_service.dart';
import 'dart:convert';

class ForgotPasswordEmailView extends StatefulWidget {
  const ForgotPasswordEmailView({super.key});

  @override
  State<ForgotPasswordEmailView> createState() =>
      _ForgotPasswordEmailViewState();
}

class _ForgotPasswordEmailViewState extends State<ForgotPasswordEmailView> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendOTP() async {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Call the sendOTP method and get the full response
      final response = await AuthService.sendOTP(
          emailController.text); // Fetch the full HTTP response

      // Check if the response was successful
      if (response.statusCode == 200) {
        // Decode the response body into a JSON map (only after a successful status code)
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Navigate to the OTP verification screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordVerificationView(
              email: emailController.text,
            ),
          ),
        );

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseBody['message'] ?? 'OTP sent successfully')),
        );
      } else {
        // Decode and handle error responses
        final errorBody = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorBody['message'] ?? 'Failed to send OTP')),
        );
      }
    } catch (e) {
      // Handle any exceptions, such as network or decoding errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false); // Reset the loading state
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your email address:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Verification Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
