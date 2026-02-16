import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../models/intensity.dart';
import '../../models/intensity_stat.dart';
import '../../widgets/current_intensity_card.dart';
import '../../widgets/intensity_chart_card.dart';
import '../../widgets/insight_tiles_row.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController controller = DashboardController();

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool showSnack = false}) async {
    try {
      await controller.loadDashboard();

      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        error = e.toString();
      });

      if (showSnack && error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error!),
            action: SnackBarAction(
              label: AppStrings.retry,
              onPressed: () {
                setState(() => isLoading = true);
                load(showSnack: true);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && controller.currentIntensity == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (controller.currentIntensity == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.appTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(error ?? AppStrings.errorSomethingWrong),
          ),
        ),
      );
    }

    final Intensity current = controller.currentIntensity!;
    final List<Intensity> list = controller.todayIntensityList;
    final IntensityStat? stat = controller.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading
                ? null
                : () {
                    setState(() => isLoading = true);
                    load(showSnack: true);
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() => isLoading = true);
            await load(showSnack: true);
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final horizontal = width < 380 ? 12.0 : 16.0;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontal,
                  vertical: 16,
                ),
                children: [
                  if (error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  CurrentIntensityCard(intensity: current),
                  const SizedBox(height: 16),

                  IntensityChartCard(intensityList: list),
                  const SizedBox(height: 16),

                  if (stat != null) InsightTilesRow(stat: stat),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
