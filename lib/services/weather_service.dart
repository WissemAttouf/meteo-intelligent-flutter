// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../config/api_config.dart';

class WeatherService {
  final String _apiKey = ApiConfig.openWeatherApiKey;
  final String _openWeatherUrl = 'https://api.openweathermap.org/data/2.5';
  final String _openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<WeatherData> fetchWeather(String city) async {
    // 1. Géocodage
    final geocodingUrl = Uri.parse(
        '$_openWeatherUrl/weather?q=$city&appid=$_apiKey&units=metric');
    final geocodingResponse = await http.get(geocodingUrl);

    if (geocodingResponse.statusCode != 200) {
      throw Exception('Ville non trouvée. Veuillez vérifier l\'orthographe.');
    }

    final geoData = jsonDecode(geocodingResponse.body) as Map<String, dynamic>;
    // Accès sécurisé aux coordonnées
    final lat = (geoData['coord']?['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (geoData['coord']?['lon'] as num?)?.toDouble() ?? 0.0;
    final actualCity = geoData['name'] as String? ?? city;

    // 2. Récupération des données Météo
    final weatherUrl = Uri.parse(
        '$_openMeteoUrl?latitude=$lat&longitude=$lon&hourly=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code&daily=weather_code,temperature_2m_max,temperature_2m_min,sunrise,sunset&current_weather=true&timezone=auto');

    final weatherResponse = await http.get(weatherUrl);

    if (weatherResponse.statusCode != 200) {
      throw Exception('Erreur lors de la récupération des données météo.');
    }

    final weatherJson = jsonDecode(weatherResponse.body) as Map<String, dynamic>;
    // Sécurisation de la récupération des maps
    final current = weatherJson['current_weather'] as Map<String, dynamic>? ?? {};
    final daily = weatherJson['daily'] as Map<String, dynamic>? ?? {};
    final hourly = weatherJson['hourly'] as Map<String, dynamic>? ?? {};

    // --- FIX 3 (Gestion de la nullité pour éviter TypeError) ---
    final now = DateTime.now();
    final nowHour = now.hour;

    final List<dynamic> hourlyTimes = hourly['time'] as List<dynamic>? ?? [];

    final int hourIndex = hourlyTimes.indexWhere((time) =>
    DateTime.parse(time as String).hour == nowHour &&
        DateTime.parse(time).day == now.day
    );

    final effectiveIndex = hourIndex != -1 ? hourIndex : 0;

    // Accès sécurisé aux données
    final temperatureList = hourly['temperature_2m'] as List<dynamic>?;
    final humidityList = hourly['relative_humidity_2m'] as List<dynamic>?;

    final currentTemp = (current['temperature'] as num?)?.toDouble() ?? 0.0;

    // Assure que les valeurs existent et sont converties correctement
    final feelsLike = (temperatureList != null && temperatureList.length > effectiveIndex)
        ? (temperatureList[effectiveIndex] as num?)?.toDouble() ?? currentTemp
        : currentTemp;

    final humidity = (humidityList != null && humidityList.length > effectiveIndex)
        ? (humidityList[effectiveIndex] as num?)?.round() ?? 70
        : 70;

    final windSpeed = (current['wind_speed'] as num?)?.toDouble() ?? 0.0;
    // FIX 3: Correction de l'erreur int: Assure que weatherCode est un int (ou 0 par défaut)
    final weatherCode = (current['weather_code'] as int?) ?? 0;

    // Définitions de secours
    final pressure = 1013;
    final visibility = 10000;

    // Fonction de mapping simple (sera gérée par weather_utils pour l'affichage)
    String getCondition(int wmoCode) {
      if (wmoCode == 0) return 'Ciel dégagé';
      if (wmoCode >= 51 && wmoCode <= 65) return 'Pluie';
      if (wmoCode >= 95) return 'Orage';
      return 'Météo Inconnue';
    }

    // Prévisions Quotidiennes (Daily Forecasts)
    final List<DailyForecast> dailyForecasts = [];
    final List<dynamic> dailyTimes = daily['time'] as List<dynamic>? ?? [];
    final List<dynamic> maxTempList = daily['temperature_2m_max'] as List<dynamic>? ?? [];
    final List<dynamic> minTempList = daily['temperature_2m_min'] as List<dynamic>? ?? [];
    final List<dynamic> codeList = daily['weather_code'] as List<dynamic>? ?? [];

    if (dailyTimes.isNotEmpty) {
      for (int i = 0; i < dailyTimes.length && i < 5; i++) {
        // Accès sécurisé aux éléments de la liste
        final maxTemp = (maxTempList.length > i) ? (maxTempList[i] as num?)?.toDouble() ?? 0.0 : 0.0;
        final minTemp = (minTempList.length > i) ? (minTempList[i] as num?)?.toDouble() ?? 0.0 : 0.0;
        final dailyCode = (codeList.length > i) ? (codeList[i] as int?) ?? 0 : 0;

        dailyForecasts.add(
          DailyForecast(
            date: DateTime.parse(dailyTimes[i] as String),
            maxTemp: maxTemp,
            minTemp: minTemp,
            weatherCode: dailyCode,
            condition: getCondition(dailyCode),
          ),
        );
      }
    }

    // Lever et Coucher du Soleil (gestion de la nullité)
    final sunriseTimes = daily['sunrise'] as List<dynamic>?;
    final sunsetTimes = daily['sunset'] as List<dynamic>?;

    final sunrise = (sunriseTimes != null && sunriseTimes.isNotEmpty && sunriseTimes[0] is String)
        ? DateTime.parse(sunriseTimes[0] as String)
        : DateTime.now().subtract(const Duration(hours: 4));

    final sunset = (sunsetTimes != null && sunsetTimes.isNotEmpty && sunsetTimes[0] is String)
        ? DateTime.parse(sunsetTimes[0] as String)
        : DateTime.now().add(const Duration(hours: 4));

    // Construction de l'objet WeatherData
    return WeatherData(
      city: actualCity,
      temperature: currentTemp,
      weatherCode: weatherCode,
      condition: getCondition(weatherCode),
      humidity: humidity,
      windSpeed: windSpeed,
      dailyForecasts: dailyForecasts,
      pressure: pressure,
      feelsLike: feelsLike,
      visibility: visibility,
      sunrise: sunrise,
      sunset: sunset,
    );
  }

  void debugAPI() {
    print('Service API Météo en cours d\'utilisation.');
  }
}