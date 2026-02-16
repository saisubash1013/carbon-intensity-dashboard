import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants/app_theme.dart';
import '../core/constants/app_strings.dart';
import '../models/intensity.dart';

class IntensityChartCard extends StatelessWidget {
  final List<Intensity> intensityList;

  const IntensityChartCard({super.key, required this.intensityList});

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final chartH = (screenH * 0.28).clamp(180.0, 280.0);

    final lastActualInterval = intensityList
        .where((e) => e.actual != null)
        .map((e) => DateTime.parse(e.from))
        .fold<DateTime?>(
          null,
          (prev, t) => prev == null || t.isAfter(prev) ? t : prev,
        );

    if (lastActualInterval == null) {
      return _card(child: const _EmptyChart(message: AppStrings.noActualData));
    }

    final nowUtc = DateTime.now().toUtc();
    final todayStartUtc = DateTime.utc(nowUtc.year, nowUtc.month, nowUtc.day);

    final isBefore0530 =
        (nowUtc.hour < 5) || (nowUtc.hour == 5 && nowUtc.minute < 30);

    DateTime windowStartUtc;
    DateTime windowEndForecastUtc;

    if (isBefore0530) {
      windowStartUtc = todayStartUtc;
      windowEndForecastUtc = todayStartUtc.add(const Duration(hours: 6));
    } else {
      final windowEndActual = lastActualInterval;

      final hasAtLeast5HoursActual = _hasAtLeastHoursOfActual(
        intensityList,
        windowEndActual,
        5,
      );

      final forecastHours = hasAtLeast5HoursActual ? 1 : 6;

      windowStartUtc = windowEndActual.subtract(const Duration(hours: 5));
      windowEndForecastUtc = windowEndActual.add(
        Duration(hours: forecastHours),
      );
      if (windowStartUtc.isBefore(todayStartUtc)) {
        windowStartUtc = todayStartUtc;
      }
    }

    final windowed =
        intensityList
            .map((e) => _ParsedIntensity(e))
            .where((p) => !p.fromUtc.isBefore(windowStartUtc))
            .where((p) => !p.fromUtc.isAfter(windowEndForecastUtc))
            .toList()
          ..sort((a, b) => a.fromUtc.compareTo(b.fromUtc));

    if (windowed.isEmpty) {
      return _card(child: const _EmptyChart(message: AppStrings.noWindowData));
    }

    double xOf(DateTime tUtc) {
      final minutes = tUtc.difference(windowStartUtc).inMinutes;
      return minutes / 30.0;
    }

    final actualSpots = <FlSpot>[];
    final forecastSpots = <FlSpot>[];

    for (final p in windowed) {
      if (p.actual != null) {
        actualSpots.add(FlSpot(xOf(p.fromUtc), p.actual!.toDouble()));
      }
      if (p.forecast != null) {
        forecastSpots.add(FlSpot(xOf(p.fromUtc), p.forecast!.toDouble()));
      }
    }

    final showActualDots = actualSpots.length < 2;

    final plottedY = <double>[
      ...actualSpots.map((s) => s.y),
      ...forecastSpots.map((s) => s.y),
    ];

    if (plottedY.isEmpty) {
      return _card(child: const _EmptyChart(message: AppStrings.noNumericData));
    }

    final rawMin = plottedY.reduce((a, b) => a < b ? a : b);
    final rawMax = plottedY.reduce((a, b) => a > b ? a : b);

    final yAxis = _buildYAxis(rawMin, rawMax);

    final lineChart = LineChart(
      _buildChartData(
        actualSpots: actualSpots,
        forecastSpots: forecastSpots,
        minY: yAxis.minY,
        maxY: yAxis.maxY,
        yInterval: yAxis.step,
        windowStartUtc: windowStartUtc,
        showActualDots: showActualDots,
      ),
      duration: const Duration(milliseconds: 250),
    );

    return _card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              AppStrings.chartTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.chartSubtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            SizedBox(height: chartH, child: lineChart),
            const SizedBox(height: 8),
            _LegendRow(),
          ],
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: child,
    );
  }

  bool _hasAtLeastHoursOfActual(
    List<Intensity> items,
    DateTime lastActualTime,
    int hours,
  ) {
    final start = lastActualTime.subtract(Duration(hours: hours));
    final requiredPoints = hours * 2;

    final count = items.where((e) {
      if (e.actual == null) return false;
      final t = DateTime.parse(e.from);
      return !t.isBefore(start) && !t.isAfter(lastActualTime);
    }).length;

    return count >= requiredPoints;
  }

  LineChartData _buildChartData({
    required List<FlSpot> actualSpots,
    required List<FlSpot> forecastSpots,
    required double minY,
    required double maxY,
    required double yInterval,
    required DateTime windowStartUtc,
    required bool showActualDots,
  }) {
    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: yInterval,
        verticalInterval: 2,
        getDrawingHorizontalLine: (value) =>
            FlLine(strokeWidth: 1, color: Colors.grey.withOpacity(0.20)),
        getDrawingVerticalLine: (value) =>
            FlLine(strokeWidth: 1, color: Colors.grey.withOpacity(0.15)),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: yInterval,
            reservedSize: 44,
            getTitlesWidget: (value, meta) => Text(
              value.toInt().toString(),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final slot = value.round();
              if (slot % 2 != 0) return const SizedBox.shrink();

              final tLocal = windowStartUtc
                  .add(Duration(minutes: slot * 30))
                  .toLocal();

              final hh = tLocal.hour.toString().padLeft(2, '0');
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("$hh:00", style: const TextStyle(fontSize: 11)),
              );
            },
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((barSpot) {
              final slot = barSpot.x.round();
              final tLocal = windowStartUtc
                  .add(Duration(minutes: slot * 30))
                  .toLocal();

              final hh = tLocal.hour.toString().padLeft(2, '0');
              final mm = tLocal.minute.toString().padLeft(2, '0');

              final label = barSpot.barIndex == 0
                  ? AppStrings.forecast
                  : AppStrings.actual;

              return LineTooltipItem(
                "$label\n$hh:$mm\n${barSpot.y.toInt()}",
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              );
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        // Forecast (barIndex 0)
        LineChartBarData(
          spots: forecastSpots,
          isCurved: true,
          barWidth: 3,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.forecast,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: Colors.blue.withOpacity(0.10),
          ),
          color: AppColors.forecast,
        ),

        // Actual (barIndex 1)
        LineChartBarData(
          spots: actualSpots,
          isCurved: true,
          barWidth: 4,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.actual,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
          ),
          belowBarData: BarAreaData(show: false),
          color: AppColors.actual,
        ),
      ],
    );
  }
}

class _ParsedIntensity {
  _ParsedIntensity(this.raw)
    : fromUtc = DateTime.parse(raw.from),
      toUtc = DateTime.parse(raw.to);

  final Intensity raw;
  final DateTime fromUtc;
  final DateTime toUtc;

  int? get forecast => raw.forecast;
  int? get actual => raw.actual;
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Text(message, style: TextStyle(color: Colors.grey.shade700)),
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget dot(Color c) => Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );

    return Row(
      children: [
        dot(AppColors.actual),
        const SizedBox(width: 6),
        const Text(AppStrings.actual, style: TextStyle(fontSize: 12)),
        const SizedBox(width: 16),
        dot(AppColors.forecast),
        const SizedBox(width: 6),
        const Text(AppStrings.forecast, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _YAxis {
  final double minY;
  final double maxY;
  final double step;
  const _YAxis({required this.minY, required this.maxY, required this.step});
}

_YAxis _buildYAxis(double minVal, double maxVal) {
  final range = (maxVal - minVal).abs();

  if (range < 1) {
    final minY = (minVal - 5).clamp(0, double.infinity);
    final maxY = maxVal + 5;
    return _YAxis(minY: minY.toDouble(), maxY: maxY, step: 2.0);
  }

  final rawStep = range / 6.0;

  final step = _snapStep(rawStep);

  final minY = (minVal / step).floor() * step;
  final maxY = (maxVal / step).ceil() * step;

  return _YAxis(minY: minY, maxY: maxY, step: step);
}

double _snapStep(double raw) {
  if (raw <= 2) return 2;
  if (raw <= 5) return 5;
  if (raw <= 10) return 10;
  if (raw <= 20) return 20;
  if (raw <= 25) return 25;
  if (raw <= 50) return 50;
  return 100;
}
