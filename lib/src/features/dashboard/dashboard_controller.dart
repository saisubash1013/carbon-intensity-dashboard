import '../../api/carbon_intensity_api.dart';
import '../../models/intensity.dart';
import '../../models/intensity_stat.dart';

class DashboardController {
  Intensity? currentIntensity;
  List<Intensity> todayIntensityList = [];
  IntensityStat? stats;

  Future<void> loadDashboard() async {
    try {
      final currentResponse = await CarbonIntensityApi.fetchCurrentIntensity();
      currentIntensity = currentResponse.intensity.first;

      final todayDate = _getTodayDate();
      final todayResponse = await CarbonIntensityApi.fetchIntensityByDate(
        todayDate,
      );
      todayIntensityList = todayResponse.intensity;
      stats = _calculateStats(todayIntensityList);
    } catch (e, stackTrace) {
      // print("ERROR TYPE: ${e.runtimeType}");
      // print("ERROR MESSAGE: $e");
      // print("STACK TRACE:");
      // print(stackTrace);
      rethrow;
    }
  }

  String _getTodayDate() {
    final now = DateTime.now().toUtc();
    final year = now.year.toString().padLeft(4, '0');
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return "$year-$month-$day";
  }

  IntensityStat? _calculateStats(List<Intensity> items) {
    final values = items
        .map((e) => e.actual ?? e.forecast)
        .whereType<int>()
        .toList();

    if (values.isEmpty) return null;

    values.sort();

    final min = values.first;
    final max = values.last;

    final sum = values.reduce((a, b) => a + b);
    final avg = (sum / values.length).round();

    return IntensityStat(
      from: items.first.from,
      to: items.last.to,
      min: min,
      max: max,
      average: avg,
      index: "today",
    );
  }
}
