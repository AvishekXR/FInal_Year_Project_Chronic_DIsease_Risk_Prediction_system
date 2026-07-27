import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'core/app_provider.dart';
import 'core/constants.dart';
import 'screens/user_login_screen.dart';
import 'screens/web_landing_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chronic Disease Risk Prediction System',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      // Web → landing page (choose User or Admin)
      // Phone → user login directly
      home: kIsWeb ? const WebLandingScreen() : const UserLoginScreen(),
    );
  }
}
