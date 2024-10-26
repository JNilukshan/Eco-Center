import 'package:center/view/login/forgotpasswordnewpasswordview.dart';
import 'package:flutter/material.dart';
import 'package:center/view/login/auth_service.dart';
import 'package:center/common/color_extrnsion.dart';

class ForgotPasswordVerificationView extends StatefulWidget {
  final String email;

  const ForgotPasswordVerificationView({
    super.key,
    required this.email,
  });

  @override
  State<ForgotPasswordVerificationView> createState() =>
      _ForgotPasswordVerificationViewState();
}

class _ForgotPasswordVerificationViewState
    extends State<ForgotPasswordVerificationView> {
  final TextEditingController verificationCodeController =
      TextEditingController();
  bool isLoading = false;

  Future<void> verifyOTP() async {
    if (verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await AuthService.verifyOTP(
        widget.email,
        verificationCodeController.text,
      );

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ForgotPasswordNewPasswordView(
              email: widget.email,
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification Code'),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the verification code sent to your email:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: verificationCodeController,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : verifyOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verify Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
