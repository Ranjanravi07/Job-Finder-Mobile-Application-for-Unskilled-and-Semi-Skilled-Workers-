import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

import '../services/app_store.dart';
import '../theme/app_colors.dart';

/// Mirrors the React `ROLE SELECTION` screen.
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  void _selectWorker(BuildContext context) {
    final store = AppStore.instance;
    store.setRole('worker');
    Navigator.pushNamed(context, '/worker-profile-creation');
  }

  void _selectEmployer(BuildContext context) {
    final store = AppStore.instance;
    store.setRole('employer');
    Navigator.pushNamed(context, '/employer-profile-creation');
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppStore.instance.lang;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Text(
                lang == 'ne' ? 'तपाईं को हुनुहुन्छ?' : 'Who are you?',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.slate900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'ne'
                    ? 'आफ्नो आवश्यकता अनुसार भूमिका चयन गर्नुहोस्।'
                    : 'Select the portal that fits your needs.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.slate500),
              ),
              const Expanded(child: SizedBox()),

              // Job Seeker Card (Worker)
              GestureDetector(
                onTap: () => _selectWorker(context),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.emerald500.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 50,
                          color: AppColors.emerald600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang == 'ne' ? 'जागिर खोज्ने (कामदार)' : 'Job Seeker (Worker)',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang == 'ne'
                            ? 'डकर्मी, पेन्टर, इलेक्ट्रीशियन, लेबर आदि कामहरू पाउनुहोस्।'
                            : 'Find immediate daily wage or construction works near Lalitpur.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Employer Card
              GestureDetector(
                onTap: () => _selectEmployer(context),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.slate200, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.slate900.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.business_center_rounded,
                          size: 50,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        lang == 'ne' ? 'रोजगारदाता / ठेकेदार' : 'Employer / Contractor',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lang == 'ne'
                            ? 'आफ्नो निर्माण वा अन्य कामका लागि कामदारहरू भर्ती गर्नुहोस्।'
                            : 'Post job requirements and connect with skilled laborers.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AppColors.slate500),
                      ),
                    ],
                  ),
                ),
              ),

              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
