import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'screens/login/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://eyylsacqsvaqsujjifru.supabase.co',
    anonKey: 'sb_publishable_InDc60McIyFKtEllwa10mg_mcqqU6vC',
  );

  runApp(const BaithakLibraryApp());
}

class BaithakLibraryApp extends StatelessWidget {
  const BaithakLibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baithak Library',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}