import 'package:flutter/material.dart';
import 'package:center/view/login/auth_service.dart';
import 'package:center/common/color_extrnsion.dart';
import 'package:center/view/login/loginView.dart';

class ForgotPasswordNewPasswordView extends StatefulWidget {
  final String email;

  const ForgotPasswordNewPasswordView({
    super.key,
    required this.email,
  });

  @override
  State<ForgotPasswordNewPasswordView> createState() =>
      _ForgotPasswordNewPasswordViewState();
}

class _ForgotPasswordNewPasswordViewState
    extends State<ForgotPasswordNewPasswordView> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isShow = false;
  bool isLoading = false;

  // Navigate based on user type
  void navigateToLogin() {
    final userType = AuthService.userType;
    final Widget loginView =
        userType == 'driver' ? const LoginView(userId: '',) : const LoginView(userId: '',);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => loginView,
      ),
      (route) => false,
    );
  }

  Future<void> resetPassword() async {
    if (newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await AuthService.resetPassword(
        widget.email,
        newPasswordController.text,
      );

      if (mounted) {
        navigateToLogin(); // Use the new navigation method
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
        title: const Text('New Password'),
        backgroundColor: TColor.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter a new password for your ${AuthService.userType ?? ''} account:',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isShow ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => isShow = !isShow),
                ),
              ),
              obscureText: !isShow,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    isShow ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => isShow = !isShow),
                ),
              ),
              obscureText: !isShow,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.primary,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Reset Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
