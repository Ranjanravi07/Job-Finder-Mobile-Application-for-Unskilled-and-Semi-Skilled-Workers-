import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/app_store.dart';
import '../theme/app_colors.dart';

/// Mirrors the React `LANGUAGE SELECTION` screen.
class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  void _select(BuildContext context, String lang) {
    final store = AppStore.instance;
    store.setLang(lang);
    Navigator.pushNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.slate50,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Spacer(),
              // App Logo / Symbol
              Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.appColors.slate900.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.work_outline_rounded,
                    size: 80,
                    color: context.appColors.slate900,
                  ),
                ),
              ),
              SizedBox(height: 24),
              // App Title in English and Nepali
              Text(
                'Job Finder',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: context.appColors.slate900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'जागिर खोज्ने मोबाइल एप',
                textAlign: TextAlign.center,
                style: GoogleFonts.hind(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: context.appColors.slate700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'For Unskilled & Semi-Skilled Workers',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: context.appColors.slate600,
                ),
              ),
              Spacer(),
              // Instruction
              Text(
                'Please Select Language\nकृपया भाषा छान्नुहोस्',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.appColors.slate700,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 32),
              // English Button
              ElevatedButton(
                onPressed: () => _select(context, 'en'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.slate900,
                  foregroundColor: context.appColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🇺🇸', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 12),
                    Text(
                      'English',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Nepali Button
              ElevatedButton(
                onPressed: () => _select(context, 'ne'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.appColors.white,
                  foregroundColor: context.appColors.slate900,
                  padding: EdgeInsets.symmetric(vertical: 18),
                  side: BorderSide(color: context.appColors.slate200, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('🇳🇵', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 12),
                    Text(
                      'नेपाली (Nepali)',
                      style: GoogleFonts.hind(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Center(
                child: Text(
                  'Nepal College of Information Technology',
                  style: TextStyle(
                      fontSize: 14, color: context.appColors.slate300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
