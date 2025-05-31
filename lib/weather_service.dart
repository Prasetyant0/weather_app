import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const String _apiKeyEnvVar = 'OPENWEATHER_API_KEY';
  final Duration _timeout = const Duration(seconds: 10);

  String get _apiKey {
    final key = dotenv.env[_apiKeyEnvVar];
    if (key == null || key.isEmpty) {
      throw Exception('API key not configured. Please check your .env file');
    }
    return key;
  }

  Future<WeatherData> getWeather(String city) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl?q=$city&appid=$_apiKey&units=metric'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        return _parseWeatherData(response.body, city);
      } else {
        throw _handleError(response.statusCode, city);
      }
    } catch (e) {
      throw _convertException(e);
    }
  }

  WeatherData _parseWeatherData(String responseBody, String city) {
    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return WeatherData.fromJson(json);
    } catch (e) {
      throw Exception('Failed to parse weather data for $city: $e');
    }
  }

  Exception _handleError(int statusCode, String city) {
    switch (statusCode) {
      case 401:
        return Exception(
          'Invalid API key. Please check your .env configuration',
        );
      case 404:
        return Exception('City "$city" not found');
      case 429:
        return Exception('Too many requests. Please wait before trying again');
      default:
        return Exception('Failed to load weather data (Status: $statusCode)');
    }
  }

  Exception _convertException(dynamic e) {
    if (e is TimeoutException) {
      return Exception('Request timed out. Please check your connection');
    } else if (e is http.ClientException) {
      return Exception('Network error: ${e.message}');
    }
    return Exception('Unexpected error: $e');
  }
}
