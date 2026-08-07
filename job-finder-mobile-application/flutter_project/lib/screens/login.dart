import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_store.dart';
import '../theme/app_colors.dart';

/// Mirrors the React `LOGIN` screen (OTP phone login).
class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  final bool _isLoading = false;

  AppStore get store => AppStore.instance;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    final lang = store.lang;
    store.sendOtp(
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.red500),
        );
      },
      (message) {
        setState(() {
          _otpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              lang == 'ne' ? 'ओटिपी कोड पठाइएको छ: $message' : 'OTP Code sent: $message',
            ),
            backgroundColor: AppColors.emerald500,
            duration: const Duration(seconds: 6),
          ),
        );
      },
    );
  }

  void _verifyOtp() {
    store.verifyOtp(
      _otpController.text,
      (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.red500),
        );
      },
      (existingWorker, existingEmployer) {
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
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.slate900),
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
                    ? 'सुरक्षित प्रवेशको लागि आफ्नो मोबाइल नम्बर राख्नुहोस्। पासवर्ड चाहिँदैन।'
                    : 'Enter your 10-digit mobile number. No password required.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.slate500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),

              if (!_otpSent) ...[
                Text(
                  lang == 'ne' ? 'नेपाली मोबाइल नम्बर' : 'Nepali Mobile Number',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.slate200, width: 1.5),
                      ),
                      child: const Text(
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
                        onChanged: (v) => store.setPhone(v.replaceAll(RegExp(r'\D'), '')),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '98XXXXXXXX',
                          hintStyle: const TextStyle(color: AppColors.slate400),
                          fillColor: Colors.white,
                          filled: true,
                          contentPadding: const EdgeInsets.all(16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.slate900, width: 2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slate900,
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
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  onChanged: (v) {
                    if (v.length == 6) _verifyOtp();
                  },
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '******',
                    hintStyle: const TextStyle(color: AppColors.slate400, letterSpacing: 0),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate200, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.emerald500, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.emerald500,
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
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _otpSent = false;
                      _otpController.clear();
                    });
                  },
                  child: Text(
                    lang == 'ne' ? 'नम्बर परिवर्तन गर्नुहोस्' : 'Change Phone Number',
                    style: const TextStyle(
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
