import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'dart:async';

import '../services/app_store.dart';
import '../theme/app_colors.dart';

/// Mirrors the React `LOGIN` screen (OTP phone login).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  
  Timer? _timer;
  int _countdown = 0;

  AppStore get store => AppStore.instance;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _countdown = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  bool get _isPhoneValid => _phoneController.text.replaceAll(RegExp(r'\D'), '').length == 10;
  bool get _isOtpValid => _otpController.text.trim().length == 6;

  void _sendOtp() {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    store.sendOtp(
      (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.red500,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      (message) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
            _otpController.clear();
          });
          _startTimer();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.emerald500,
              duration: const Duration(seconds: 6),
            ),
          );
        }
      },
    );
  }

  void _verifyOtp() {
    if (_isLoading) return;
    final otpCode = _otpController.text.trim();
    if (otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(store.lang == 'ne'
              ? 'कृपया ६-अंकको ओटिपी कोड हाल्नुहोस्।'
              : 'Please enter the complete 6-digit OTP code.'),
          backgroundColor: AppColors.red500,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    store.verifyOtp(
      otpCode,
      (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: AppColors.red500,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      },
      (existingWorker, existingEmployer) {
        if (mounted) {
          setState(() => _isLoading = false);
          if (existingWorker) {
            store.setRole('worker');
            Navigator.pushReplacementNamed(context, '/worker-home');
          } else if (existingEmployer) {
            store.setRole('employer');
            Navigator.pushReplacementNamed(context, '/employer-home');
          } else {
            // No profile exists - go to role selection to create profile.
            Navigator.pushReplacementNamed(context, '/role-selection');
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = store.lang;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.slate900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lang == 'ne' ? 'मोबाईल लग-इन' : 'Mobile Login',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'ne'
                    ? 'सुरक्षित प्रवेशको लागि आफ्नो मोबाइल नम्बर राख्नुहोस्।'
                    : 'Enter your 10-digit mobile number.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.slate500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              if (!_otpSent) ...[
                Text(
                  lang == 'ne' ? ' मोबाइल नम्बर' : ' Mobile Number',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200, width: 1.5),
                      ),
                      child: Text(
                        '+977',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        onChanged: (v) {
                          store.setPhone(v.replaceAll(RegExp(r'\D'), ''));
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '98XXXXXXXX',
                          hintStyle: TextStyle(color: AppColors.slate400),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.slate200, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: AppColors.slate900, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_isLoading || !_isPhoneValid) ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isLoading || !_isPhoneValid)
                        ? AppColors.slate300
                        : AppColors.slate900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          lang == 'ne' ? 'ओटिपी पठाउनुहोस्' : 'Send OTP Verification Code',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ] else ...[
                Text(
                  lang == 'ne' ? '६-अंकको ओटिपी कोड हाल्नुहोस्' : '6-Digit OTP Code',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Pinput(
                    controller: _otpController,
                    length: 6,
                    onChanged: (v) => setState(() {}),
                    onCompleted: (v) => _verifyOtp(),
                    defaultPinTheme: PinTheme(
                      width: 50,
                      height: 56,
                      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.slate900),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200, width: 1.5),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 50,
                      height: 56,
                      textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.slate900),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.emerald500, width: 2),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: (_isLoading || !_isOtpValid) ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_isLoading || !_isOtpValid)
                        ? AppColors.slate300
                        : AppColors.emerald500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          lang == 'ne' ? 'कोड प्रमाणित गर्नुहोस्' : 'Verify & Proceed',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      lang == 'ne' ? 'कोड आएन? ' : 'Didn\'t receive the code? ',
                      style: TextStyle(color: AppColors.slate500),
                    ),
                    TextButton(
                      onPressed: (_countdown == 0 && !_isLoading) ? _sendOtp : null,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        _countdown > 0 
                          ? (lang == 'ne' ? '$_countdown सेकेन्डमा पुनः पठाउनुहोस्' : 'Resend OTP in ${_countdown}s')
                          : (lang == 'ne' ? 'पुनः पठाउनुहोस्' : 'Resend OTP'),
                        style: TextStyle(
                          color: _countdown == 0 ? AppColors.emerald500 : AppColors.slate400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _isLoading = false;
                      _otpController.clear();
                    });
                  },
                  child: Text(
                    lang == 'ne' ? 'नम्बर परिवर्तन गर्नुहोस्' : 'Change Phone Number',
                    style: TextStyle(
                      color: AppColors.slate900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
