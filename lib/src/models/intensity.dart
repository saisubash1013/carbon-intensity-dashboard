class CarbonIntensity {
  final List<Intensity> intensity;

  CarbonIntensity({required this.intensity});

  factory CarbonIntensity.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List;

    final intensities = dataList.map((item) {
      return Intensity.fromJson(item);
    }).toList();

    return CarbonIntensity(intensity: intensities);
  }
}

class Intensity {
  final String from;
  final String to;

  final int? forecast;
  final int? actual;

  final String index;

  Intensity({
    required this.from,
    required this.to,
    required this.forecast,
    required this.actual,
    required this.index,
  });

  factory Intensity.fromJson(Map<String, dynamic> json) {
    final intensityJson = json['intensity'] as Map<String, dynamic>;

    return Intensity(
      from: json['from'] as String,
      to: json['to'] as String,

      forecast: intensityJson['forecast'] == null
          ? null
          : intensityJson['forecast'] as int,

      actual: intensityJson['actual'] == null
          ? null
          : intensityJson['actual'] as int,

      index: intensityJson['index'] as String,
    );
  }
}
