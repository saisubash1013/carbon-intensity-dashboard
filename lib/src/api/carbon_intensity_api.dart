import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../core/constants/app_strings.dart';
import '../core/errors/api_exception.dart';
import '../models/intensity.dart';

class CarbonIntensityApi {
  static const String _baseUrl = "https://api.carbonintensity.org.uk/intensity";

  // get current intensity
  static Future<CarbonIntensity> fetchCurrentIntensity() async {
    final uri = Uri.parse(_baseUrl);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException("Failed to fetch current intensity");
      }

      final json = jsonDecode(response.body);
      return CarbonIntensity.fromJson(json);
    } on SocketException {
      throw ApiException(AppStrings.errorNoInternet);
    } on http.ClientException {
      throw ApiException(AppStrings.errorNoInternet);
    } on TimeoutException {
      throw ApiException("Request timed out. Please try again.");
    } catch (_) {
      throw ApiException(AppStrings.errorSomethingWrong);
    }
  }

  // get intensity by date
  static Future<CarbonIntensity> fetchIntensityByDate(String date) async {
    final uri = Uri.parse("$_baseUrl/date/$date");

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw ApiException("Failed to fetch intensity by date");
      }

      final json = jsonDecode(response.body);
      return CarbonIntensity.fromJson(json);
    } on SocketException {
      throw ApiException(AppStrings.errorNoInternet);
    } on http.ClientException {
      throw ApiException(AppStrings.errorNoInternet);
    } on TimeoutException {
      throw ApiException("Request timed out. Please try again.");
    } catch (_) {
      throw ApiException(AppStrings.errorSomethingWrong);
    }
  }
}
