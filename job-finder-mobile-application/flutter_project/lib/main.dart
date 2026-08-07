import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/employer_home.dart';
import 'screens/employer_profile_creation.dart';
import 'screens/language_selection.dart';
import 'screens/login.dart';
import 'screens/role_selection.dart';
import 'screens/worker_home.dart';
import 'screens/worker_profile_creation.dart';
import 'services/app_store.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppStore.instance.init();
  runApp(const JobFinderApp());
}

class JobFinderApp extends StatelessWidget {
  const JobFinderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Job Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.slate900,
          primary: AppColors.slate900,
          secondary: AppColors.emerald500,
          surface: AppColors.slate50,
        ),
        scaffoldBackgroundColor: AppColors.slate50,
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
        Locale('en', ''),
        Locale('ne', ''),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const LanguageSelectionScreen(),
        '/login': (context) => const LoginScreen(),
        '/role-selection': (context) => const RoleSelectionScreen(),
        '/worker-profile-creation': (context) =>
            const WorkerProfileCreationScreen(),
        '/employer-profile-creation': (context) =>
            const EmployerProfileCreationScreen(),
        '/worker-home': (context) => const WorkerHomeScreen(),
        '/employer-home': (context) => const EmployerHomeScreen(),
      },
    );
  }
}
