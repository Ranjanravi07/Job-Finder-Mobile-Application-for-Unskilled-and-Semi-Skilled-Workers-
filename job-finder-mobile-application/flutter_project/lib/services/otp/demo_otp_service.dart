import 'dart:math';
import 'package:flutter/foundation.dart';
import 'otp_service.dart';

class _OtpData {
  final String otp;
  final DateTime createdAt;
  int failedAttempts;

  _OtpData({
    required this.otp,
    required this.createdAt,
  }) : failedAttempts = 0;
}

class DemoOtpService implements OtpService {
  // Store OTPs by phone number
  final Map<String, _OtpData> _otpStorage = {};

  final int maxAttempts = 3;
  final Duration expiryDuration = const Duration(minutes: 5);

  @override
  Future<void> sendOtp(String phoneNumber) async {
    // Generate a 6-digit random code
    final String generatedOtp = (Random().nextInt(900000) + 100000).toString();

    // Store the OTP
    _otpStorage[phoneNumber] = _OtpData(
      otp: generatedOtp,
      createdAt: DateTime.now(),
    );

    // Print to console for demo purposes
    if (kDebugMode) {
      print('================================================');
      print(' OTP for $phoneNumber: $generatedOtp');
      print('================================================');
    }
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    final otpData = _otpStorage[phoneNumber];

    if (otpData == null) {
      throw OtpInvalidException('No OTP requested for this number.');
    }

    if (DateTime.now().difference(otpData.createdAt) > expiryDuration) {
      _otpStorage.remove(phoneNumber); // Clean up
      throw OtpExpiredException();
    }

    if (otpData.failedAttempts >= maxAttempts) {
      throw OtpMaxAttemptsException();
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (otpData.otp == otp) {
      // Success, remove OTP
      _otpStorage.remove(phoneNumber);
      return true;
    } else {
      otpData.failedAttempts++;
      if (otpData.failedAttempts >= maxAttempts) {
        throw OtpMaxAttemptsException();
      }
      throw OtpInvalidException();
    }
  }
}
