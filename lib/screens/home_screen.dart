// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart'; // Assurez-vous d'avoir ce modèle
import '../services/weather_service.dart'; // Assurez-vous d'avoir ce service
import '../utils/weather_utils.dart'; // ESSENTIEL: Utilitaires pour icônes/couleurs/dates
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? initialCity; // Permet de charger une ville depuis la page Favorites
  const HomeScreen({super.key, this.initialCity});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _cityController = TextEditingController();
  final WeatherService _weatherService = WeatherService();

  WeatherData? _currentWeather;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Utiliser la locale française (initialisée dans main.dart)
    Intl.defaultLocale = 'fr_FR';
    // Charger la ville passée ou 'Paris' par défaut
    final cityToLoad = widget.initialCity ?? 'Paris';
    _fetchWeather(cityToLoad);
  }

  // Utiliser didUpdateWidget pour recharger la météo si la ville change via navigation
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCity != oldWidget.initialCity && widget.initialCity != null) {
      _fetchWeather(widget.initialCity!);
    }
  }


  Future<void> _fetchWeather(String city) async {
    if (city.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final weatherData = await _weatherService.fetchWeather(city);
      setState(() {
        _currentWeather = weatherData;
        _isLoading = false;
      });
      _cityController.text = weatherData.city;
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Erreur de chargement: ${e.toString()}');
    }
  }

  void _debugAPI() {
    _weatherService.debugAPI();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Widgets de construction de l'interface ---

  @override
  Widget build(BuildContext context) {
    final weather = _currentWeather;
    final now = DateTime.now();

    // Détermination Jour/Nuit pour le dégradé
    // Utilise les heures de lever/coucher du soleil récupérées par le service
    final isDay = weather != null && weather.sunrise.isBefore(now) && weather.sunset.isAfter(now);

    // Dégradé Dynamique basé sur la météo (via weather_utils.dart)
    final gradientColors = weather != null
        ? WeatherUtils.getWeatherGradient(weather.weatherCode, isDay)
        : [Colors.blue.shade800, Colors.lightBlue.shade300]; // Dégradé par défaut (ciel bleu)

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Météo Simple'),
        backgroundColor: Colors.transparent, // Rendre l'AppBar transparente
        elevation: 0,
        foregroundColor: Colors.white, // Texte blanc pour le design dynamique
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugAPI,
            tooltip: 'Debug API',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              // Navigation vers l'écran des favoris
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoritesScreen()),
              );
            },
            tooltip: 'Villes Favorites',
          ),
        ],
      ),
      body: Container(
        // Le corps entier utilise le dégradé dynamique
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
        ),
        // Ajouter un padding pour le contenu sous l'AppBar
        padding: const EdgeInsets.only(top: kToolbarHeight + 40.0, left: 16.0, right: 16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildWeatherContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _cityController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Rechercher une ville...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
              ),
              onSubmitted: (city) => _fetchWeather(city.trim()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.blue),
            onPressed: () {
              final city = _cityController.text.trim();
              if (city.isNotEmpty) _fetchWeather(city);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherContent() {
    if (_isLoading) {
      return _buildLoadingState();
    } else if (_currentWeather != null) {
      return _buildWeatherState();
    } else {
      return _buildInitialState();
    }
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 20),
          Text(
            'Chargement des données météo...',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny, size: 100, color: Colors.white.withOpacity(0.8)),
          const SizedBox(height: 20),
          const Text(
            'Recherchez une ville pour voir la météo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherState() {
    final weather = _currentWeather!;

    // Récupère les recommandations d'activité (implémentées dans weather_utils.dart)
    final recommendations = WeatherUtils.getActivityRecommendations(
      weather.weatherCode,
      weather.temperature,
      3.0,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildCurrentWeather(weather),
          const SizedBox(height: 20),
          _buildWeatherDetails(weather),
          const SizedBox(height: 20),
          _buildRecommendations(recommendations),
          const SizedBox(height: 20),
          _buildDailyForecasts(weather.dailyForecasts),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCurrentWeather(WeatherData weather) {
    // Utilisation de WeatherUtils pour le mapping WMO vers Emoji/Label/Couleur
    final appearance = WeatherUtils.getAppearance(weather.weatherCode);

    return Card(
      elevation: 5,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              weather.city,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: appearance.primaryColor, // Couleur dynamique
              ),
            ),
            const SizedBox(height: 20),
            Text(
              appearance.emoji, // Emoji dynamique
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 10),
            Text(
              '${weather.temperature.round()}°C',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              appearance.label, // Condition textuelle dynamique
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(List<String> recommendations) {
    if (recommendations.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Conseils d\'Activité',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: recommendations.map((rec) {
            return Chip(
              label: Text(rec, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.yellow.shade100,
              avatar: const Icon(Icons.check, size: 16, color: Colors.green),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWeatherDetails(WeatherData weather) {
    return Card(
      elevation: 5,
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(Icons.opacity, 'Humidité', '${weather.humidity}%'),
                _buildDetailItem(Icons.air, 'Vent', '${weather.windSpeed.round()} km/h'),
                _buildDetailItem(Icons.compress, 'Pression', '${weather.pressure} hPa'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem(Icons.thermostat, 'Ressenti', '${weather.feelsLike.round()}°C'),
                _buildDetailItem(Icons.visibility, 'Visibilité', '${(weather.visibility / 1000).round()} km'),
                _buildSunInfo(weather),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSunInfo(WeatherData weather) {
    return Column(
      children: [
        const Icon(Icons.wb_sunny, size: 24, color: Colors.orange),
        const SizedBox(height: 4),
        const Text('Soleil', style: TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          // Utilisation d'un format de temps simple (HH:MM)
          '${_formatTime(weather.sunrise)}/${_formatTime(weather.sunset)}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatTime(DateTime time) {
    // Helper pour formater l'heure en HH:MM
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDailyForecasts(List<DailyForecast> forecasts) {
    if (forecasts.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prévisions 5 Jours',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 5,
          color: Colors.white.withOpacity(0.9),
          child: Column(
            children: forecasts.map((forecast) {
              final forecastAppearance = WeatherUtils.getAppearance(forecast.weatherCode);
              return ListTile(
                leading: Text(
                  forecastAppearance.emoji, // Emoji dynamique
                  style: const TextStyle(fontSize: 30),
                ),
                title: Text(
                  WeatherUtils.formatWeatherDate(forecast.date), // Formatage de la date en français
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(forecastAppearance.label),
                trailing: Text(
                  '${forecast.maxTemp.round()}° / ${forecast.minTemp.round()}°',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}