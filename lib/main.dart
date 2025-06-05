import 'package:agrocuy/features/auth/presentation/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:agrocuy/features/auth/presentation/login/login_screen.dart';
import 'features/advisors/presentation/advisorDetailScreen.dart';
import 'firebase_options.dart';
import 'infrastructure/services/session_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SessionService().init();

  // ¡IMPORTANTE! Para que el calendario en 'es_ES' funcione
  await initializeDateFormatting('es_ES');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgroCuy',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/advisor-detail': (context) => const AdvisorDetailScreen(),
      },
    );
  }
}
