import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/language_selection.dart';
import 'screens/login.dart';
import 'screens/role_selection.dart';
import 'screens/worker_home.dart';
import 'screens/employer_home.dart';

void main() {
  // To use real Firebase, uncomment these lines and configure Firebase in your platform folders:
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
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
          seedColor: const Color(0xFF0F172A), // Slate 900
          primary: const Color(0xFF0F172A),
          secondary: const Color(0xFF10B981), // Emerald 500
          background: const Color(0xFFF8FAFC), // Slate 50
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
      },
    );
  }
}
