import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/language_selection.dart';
import 'screens/login.dart';
import 'screens/role_selection.dart';
import 'screens/worker_home.dart';
import 'screens/employer_home.dart';
import 'screens/worker_profile_creation.dart';
import 'screens/employer_profile_creation.dart';
import 'theme/app_theme.dart';
import 'services/app_store.dart';

import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const JobFinderApp());
}

class JobFinderApp extends StatefulWidget {
  const JobFinderApp({super.key});

  @override
  State<JobFinderApp> createState() => _JobFinderAppState();
}

class _JobFinderAppState extends State<JobFinderApp> {
  @override
  void initState() {
    super.initState();
    AppStore.instance.init();
  }

  ThemeMode _getThemeMode() {
    final pref = AppStore.instance.themePref;
    if (pref == 'light') return ThemeMode.light;
    if (pref == 'dark') return ThemeMode.dark;
    return ThemeMode.system;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStore.instance,
      builder: (context, child) {
        return MaterialApp(
          title: 'Job Finder',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _getThemeMode(),
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
            '/worker-profile-creation': (context) =>
                const WorkerProfileCreationScreen(),
            '/employer-profile-creation': (context) =>
                const EmployerProfileCreationScreen(),
          },
        );
      },
    );
  }
}
