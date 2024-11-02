import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://localhost:5000/api/auth';
  static String? _userType;

  static String? get userType => _userType;

  // Send OTP
  static Future<http.Response> sendOTP(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception(
            'Failed to send OTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  // Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(
      String email, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _userType = data['userType'];
        return data;
      } else {
        throw Exception(
            'Failed to verify OTP: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword(
      String email, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
            'Failed to reset password: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }
}

