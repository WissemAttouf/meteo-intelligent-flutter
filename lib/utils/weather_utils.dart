// lib/utils/weather_utils.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math';

// Mapping WMO code sans animations
Map<int, WeatherAppearance> weatherCodeAppearance = {
  0: WeatherAppearance('Ciel dégagé', '☀️', Colors.orange),
  1: WeatherAppearance('Principalement dégagé', '🌤️', Colors.orangeAccent),
  2: WeatherAppearance('Partiellement nuageux', '⛅', Colors.lightBlue),
  3: WeatherAppearance('Couvert', '☁️', Colors.blueGrey),
  45: WeatherAppearance('Brouillard', '🌫️', Colors.grey),
  48: WeatherAppearance('Brouillard givrant', '❄️🌫️', Colors.blueGrey),
  51: WeatherAppearance('Bruine légère', '🌦️', Colors.blue),
  53: WeatherAppearance('Bruine modérée', '🌧️', Colors.blue),
  55: WeatherAppearance('Bruine dense', '🌧️', Colors.blue),
  61: WeatherAppearance('Pluie légère', '🌦️', Colors.blue),
  63: WeatherAppearance('Pluie modérée', '🌧️', Colors.blue),
  65: WeatherAppearance('Pluie forte', '💧', Colors.blue),
  71: WeatherAppearance('Neige légère', '🌨️', Colors.blue),
  73: WeatherAppearance('Neige modérée', '❄️', Colors.blue),
  75: WeatherAppearance('Neige forte', '🌨️', Colors.blue),
  80: WeatherAppearance('Averses légères', '🌦️', Colors.blue),
  81: WeatherAppearance('Averses modérées', '🌧️', Colors.blue),
  82: WeatherAppearance('Averses violentes', '⛈️', Colors.purple),
  95: WeatherAppearance('Orage', '⛈️', Colors.deepPurple),
  96: WeatherAppearance('Orage avec grêle', '⛈️🧊', Colors.deepPurple),
};

class WeatherAppearance {
  final String label;
  final String emoji;
  final Color primaryColor;

  WeatherAppearance(this.label, this.emoji, this.primaryColor);
}

// Fonctions utilitaires avancées
class WeatherUtils {
  // Obtention de l'apparence météo
  static WeatherAppearance getAppearance(int wmoCode) {
    return weatherCodeAppearance[wmoCode] ??
        WeatherAppearance('Inconnu', '❓', Colors.grey);
  }

  // Couleur de fond dynamique basée sur l'heure et la météo
  static Color getDynamicBackground(int wmoCode, bool isDay, DateTime time) {
    final baseAppearance = getAppearance(wmoCode);

    if (!isDay) {
      // Nuit - tons plus sombres
      return _darkenColor(baseAppearance.primaryColor, 0.7);
    }

    // Jour - adapter selon l'heure
    final hour = time.hour;
    if (hour >= 6 && hour <= 10) {
      return _lightenColor(baseAppearance.primaryColor, 0.3); // Matin
    } else if (hour >= 17 && hour <= 20) {
      return _mixColors(baseAppearance.primaryColor, Colors.orange, 0.5); // Soir
    }

    return baseAppearance.primaryColor;
  }

  // Génération de dégradés complexes
  static List<Color> getWeatherGradient(int wmoCode, bool isDay) {
    final appearance = getAppearance(wmoCode);
    final baseColor = appearance.primaryColor;

    if (isDay) {
      return [
        _lightenColor(baseColor, 0.2),
        baseColor,
        _darkenColor(baseColor, 0.1),
      ];
    } else {
      return [
        _darkenColor(baseColor, 0.3),
        _darkenColor(baseColor, 0.5),
        _darkenColor(baseColor, 0.7),
      ];
    }
  }

  // Calcul du confort thermique
  static String getThermalComfort(double temperature, double humidity, double windSpeed) {
    final windChill = _calculateWindChill(temperature, windSpeed);
    final heatIndex = _calculateHeatIndex(temperature, humidity);

    if (temperature < 0) return 'Très froid';
    if (temperature < 10) return 'Froid';
    if (temperature < 20 && humidity < 70) return 'Fraîcheur agréable';
    if (temperature < 25 && humidity < 60) return 'Confortable';
    if (temperature < 30 && humidity < 50) return 'Chaud';
    if (temperature >= 30 && humidity > 70) return 'Étouffant';
    if (temperature >= 35) return 'Très chaud';

    return 'Normal';
  }

  // Indice UV en texte
  static String getUVIndexLabel(double uvIndex) {
    if (uvIndex < 3) return 'Faible';
    if (uvIndex < 6) return 'Modéré';
    if (uvIndex < 8) return 'Élevé';
    if (uvIndex < 11) return 'Très élevé';
    return 'Extrême';
  }

  // Recommandations basées sur la météo
  static List<String> getActivityRecommendations(int wmoCode, double temperature, double uvIndex) {
    final recommendations = <String>[];
    final appearance = getAppearance(wmoCode);

    // Basé sur la température
    if (temperature > 25 && uvIndex < 6) {
      recommendations.add('Parfait pour la baignade');
    }
    if (temperature.isBetween(15, 25) && wmoCode < 50) {
      recommendations.add('Idéal pour une randonnée');
    }
    if (temperature < 10 || wmoCode >= 50) {
      recommendations.add('Conseillé: activités en intérieur');
    }

    // Basé sur les conditions
    if (wmoCode == 0 || wmoCode == 1) {
      recommendations.add('Temps parfait pour un pique-nique');
    }
    if (wmoCode >= 95) {
      recommendations.add('Évitez les activités extérieures');
    }

    // Protection UV
    if (uvIndex >= 6) {
      recommendations.add('Crème solaire recommandée');
    }

    return recommendations;
  }

  // Formatage intelligent des dates
  static String formatWeatherDate(DateTime date, {bool short = false}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateDay = DateTime(date.year, date.month, date.day);

    if (dateDay == today) return short ? "Auj." : "Aujourd'hui";
    if (dateDay == tomorrow) return short ? "Dem." : "Demain";

    if (short) {
      return DateFormat('E', 'fr_FR').format(date);
    } else {
      return DateFormat('EEEE', 'fr_FR').format(date);
    }
  }

  // Calcul de la durée du jour
  static Duration getDayDuration(DateTime sunrise, DateTime sunset) {
    return sunset.difference(sunrise);
  }

  // Helper methods
  static Color _lightenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    return Color.fromARGB(
      color.alpha,
      color.red + ((255 - color.red) * factor).round(),
      color.green + ((255 - color.green) * factor).round(),
      color.blue + ((255 - color.blue) * factor).round(),
    );
  }

  static Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - factor)).round(),
      (color.green * (1 - factor)).round(),
      (color.blue * (1 - factor)).round(),
    );
  }

  static Color _mixColors(Color color1, Color color2, double ratio) {
    return Color.fromARGB(
      color1.alpha,
      (color1.red * (1 - ratio) + color2.red * ratio).round(),
      (color1.green * (1 - ratio) + color2.green * ratio).round(),
      (color1.blue * (1 - ratio) + color2.blue * ratio).round(),
    );
  }

  static double _calculateWindChill(double temperature, double windSpeed) {
    if (temperature > 10) return temperature;
    return 13.12 + 0.6215 * temperature - 11.37 * pow(windSpeed, 0.16) + 0.3965 * temperature * pow(windSpeed, 0.16);
  }

  static double _calculateHeatIndex(double temperature, double humidity) {
    if (temperature < 27) return temperature;
    return -8.78469475556 +
        1.61139411 * temperature +
        2.33854883889 * humidity +
        -0.14611605 * temperature * humidity +
        -0.012308094 * pow(temperature, 2) +
        -0.0164248277778 * pow(humidity, 2) +
        0.002211732 * pow(temperature, 2) * humidity +
        0.00072546 * temperature * pow(humidity, 2) +
        -0.000003582 * pow(temperature, 2) * pow(humidity, 2);
  }
}

// Extension pour les ranges
extension Range on num {
  bool isBetween(num from, num to) {
    return this >= from && this <= to;
  }
}