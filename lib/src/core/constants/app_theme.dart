import 'package:flutter/material.dart';

class AppColors {
  static const forecast = Colors.blue;
  static const actual = Colors.red;

  static const chipLow = Colors.green;
  static const chipModerate = Colors.orange;
  static const chipHigh = Colors.red;

  static const textSecondary = Color(0xFF6B7280);
}

class AppDimens {
  static const padding = 16.0;
  static const radius = 16.0;
  static const gap = 12.0;
}

class AppTextStyles {
  static const title = TextStyle(fontSize: 16, fontWeight: FontWeight.w700);
  static const subtitle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  static const bigNumber = TextStyle(fontSize: 40, fontWeight: FontWeight.bold);
}
