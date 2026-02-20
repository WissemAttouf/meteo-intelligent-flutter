// lib/models/weather.dart

class WeatherData {
  final String city;
  final double temperature;
  final int weatherCode;
  final String condition;
  final int humidity;
  final double windSpeed;
  final List<DailyForecast> dailyForecasts;

  // Nouvelles données optionnelles
  final int pressure;
  final double feelsLike;
  final int visibility;
  final DateTime sunrise;
  final DateTime sunset;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.weatherCode,
    required this.condition,
    required this.humidity,
    required this.windSpeed,
    required this.dailyForecasts,
    // Rendre les nouvelles données optionnelles avec des valeurs par défaut
    this.pressure = 1013,
    this.feelsLike = 0,
    this.visibility = 10000,
    required this.sunrise,
    required this.sunset,
  });
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final int weatherCode;
  final String condition;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.weatherCode,
    required this.condition,
  });
}