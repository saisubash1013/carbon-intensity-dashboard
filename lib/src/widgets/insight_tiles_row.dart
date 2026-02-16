import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/constants/app_theme.dart';
import '../models/intensity_stat.dart';

class InsightTilesRow extends StatelessWidget {
  final IntensityStat stat;

  const InsightTilesRow({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.tilesHeading, style: AppTextStyles.title),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _tile(AppStrings.min, stat.min)),
                const SizedBox(width: 12),
                Expanded(child: _tile(AppStrings.max, stat.max)),
                const SizedBox(width: 12),
                Expanded(child: _tile(AppStrings.avg, stat.average)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(String label, int? value) {
    final valueText = value?.toString() ?? "—";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Text(
            valueText,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
