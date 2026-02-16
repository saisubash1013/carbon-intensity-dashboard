import 'package:flutter/material.dart';
import 'src/features/dashboard/dashboard_screen.dart';
import 'src/core/constants/app_strings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppStrings.appTitle,
      theme: ThemeData(useMaterial3: true),
      home: const DashboardScreen(),
    );
  }
}
