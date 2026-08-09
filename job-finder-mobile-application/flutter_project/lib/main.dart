import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/language_selection.dart';
import 'screens/login.dart';
import 'screens/role_selection.dart';
import 'screens/worker_home.dart';
import 'screens/employer_home.dart';
import 'screens/worker_profile_creation.dart';
import 'screens/employer_profile_creation.dart';
import 'theme/app_colors.dart';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const JobFinderApp());
}

class JobFinderApp extends StatefulWidget {
  const JobFinderApp({Key? key}) : super(key: key);

  @override
  State<JobFinderApp> createState() => _JobFinderAppState();
}

class _JobFinderAppState extends State<JobFinderApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppColors.systemBrightness = PlatformDispatcher.instance.platformBrightness;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {
      AppColors.systemBrightness = PlatformDispatcher.instance.platformBrightness;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.slate50,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.slate900,
          primary: AppColors.slate900,
          secondary: AppColors.emerald500,
          background: AppColors.slate50,
          brightness: AppColors.systemBrightness,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('ne', ''), // Nepali
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const LanguageSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/worker-home': (context) => const WorkerHomeScreen(),
        '/employer-home': (context) => const EmployerHomeScreen(),
        '/worker-profile-creation': (context) => const WorkerProfileCreationScreen(),
        '/employer-profile-creation': (context) => const EmployerProfileCreationScreen(),
      },
    );
  }
}
