class WeatherData {
  final String city;
  final double temperature;
  final String condition;
  final double humidity;
  final double windSpeed;
  final DateTime date;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.date,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    try {
      return WeatherData(
        city: json['name']?.toString() ?? 'Unknown',
        temperature: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
        condition: json['weather'][0]['main']?.toString() ?? 'Unknown',
        humidity: (json['main']['humidity'] as num?)?.toDouble() ?? 0.0,
        windSpeed: (json['wind']['speed'] as num?)?.toDouble() ?? 0.0,
        date: DateTime.fromMillisecondsSinceEpoch(
          (json['dt'] as int?) ?? 0 * 1000,
        ),
      );
    } catch (e) {
      throw Exception('Failed to parse weather data: $e');
    }
  }
}
