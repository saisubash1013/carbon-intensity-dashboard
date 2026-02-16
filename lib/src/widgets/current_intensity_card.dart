import 'package:flutter/material.dart';
import '../models/intensity.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_theme.dart';
import 'dart:io';

class CurrentIntensityCard extends StatelessWidget {
  final Intensity intensity;

  const CurrentIntensityCard({super.key, required this.intensity});

  @override
  Widget build(BuildContext context) {
    final value = intensity.actual ?? intensity.forecast;
    final index = intensity.index;

    final dt = DateTime.parse(intensity.from).toLocal();
    final dateStr =
        "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year}";
    final timeStr =
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                const Text(
                  AppStrings.currentCarbonIntensity,
                  style: TextStyle(fontSize: 14),
                ),

                const Spacer(),

                _buildStatusChip(index),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                "$value ${AppStrings.gCO2kWh}",
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text("${AppStrings.updated} $dateStr $timeStr"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String index) {
    Color color;

    switch (index.toLowerCase()) {
      case AppStrings.low:
        color = Colors.green;
        break;

      case AppStrings.moderate:
        color = Colors.orange;
        break;

      case AppStrings.high:
        color = AppColors.actual;
        break;

      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(index),
    );
  }
}
