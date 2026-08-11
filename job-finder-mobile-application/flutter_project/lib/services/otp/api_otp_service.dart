import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'otp_service.dart';

class ApiOtpService implements OtpService {
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  @override
  Future<void> sendOtp(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'channel': 'sms',
          'purpose': 'login',
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return; // Success
      } else if (response.statusCode == 429) {
        throw Exception(
            data['message'] ?? 'Please wait before requesting another OTP.');
      } else {
        throw Exception(data['message'] ?? 'Failed to send OTP.');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Network error: Unable to connect to server.');
    }
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phoneNumber,
          'otp': otp,
          'purpose': 'login',
        }),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      }

      final errorMsg = data['message'] ?? 'Verification failed.';

      // Map backend error responses to custom exceptions if they match specific strings
      if (errorMsg.contains('expired')) {
        throw OtpExpiredException(errorMsg);
      } else if (errorMsg.contains('attempts')) {
        throw OtpMaxAttemptsException(errorMsg);
      } else {
        throw OtpInvalidException(errorMsg);
      }
    } catch (e) {
      if (e is OtpExpiredException ||
          e is OtpMaxAttemptsException ||
          e is OtpInvalidException) {
        rethrow;
      }
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      throw Exception('Connection error ($baseUrl): $cleanMsg');
    }
  }
}
