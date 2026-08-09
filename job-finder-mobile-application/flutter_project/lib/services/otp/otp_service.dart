abstract class OtpService {
  /// Sends an OTP to the provided phone number.
  Future<void> sendOtp(String phoneNumber);

  /// Verifies the provided OTP against the generated one for the phone number.
  /// Throws exceptions if the OTP is invalid, expired, or max attempts reached.
  Future<bool> verifyOtp(String phoneNumber, String otp);
}

class OtpExpiredException implements Exception {
  final String message;
  OtpExpiredException([this.message = 'OTP has expired.']);
  @override
  String toString() => message;
}

class OtpMaxAttemptsException implements Exception {
  final String message;
  OtpMaxAttemptsException([this.message = 'Maximum OTP attempts reached.']);
  @override
  String toString() => message;
}

class OtpInvalidException implements Exception {
  final String message;
  OtpInvalidException([this.message = 'Invalid OTP.']);
  @override
  String toString() => message;
}
