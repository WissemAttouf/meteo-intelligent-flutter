// lib/services/database_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseService {
  // ⚠️ IP à ajuster selon votre configuration
  final String baseUrl = "http://192.168.1.6:3000";


  void _handleError(http.Response response, String operation) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw DatabaseException(
          'Erreur $operation: ${response.statusCode} - ${response.body}'
      );
    }
  }

  // --- Favoris ---

  Future<void> addFavorite(int userId, String cityName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/favorites"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "city_name": cityName,
        "created_at": DateTime.now().toIso8601String(),
      }),
    );
    _handleError(response, 'ajout favori');
  }

  Future<List<Map<String, dynamic>>> getFavorites(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/favorites/$userId"));
    _handleError(response, 'récupération favoris');

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> removeFavorite(int favoriteId) async {
    final response = await http.delete(Uri.parse("$baseUrl/favorites/$favoriteId"));
    _handleError(response, 'suppression favori');
  }

  // --- Historique ---

  Future<void> addHistory(int userId, String cityName) async {
    final response = await http.post(
      Uri.parse("$baseUrl/history"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "city_name": cityName,
        "searched_at": DateTime.now().toIso8601String(),
      }),
    );
    _handleError(response, 'ajout historique');
  }

  Future<List<Map<String, dynamic>>> getHistory(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/history/$userId"));
    _handleError(response, 'récupération historique');

    final List<dynamic> jsonList = jsonDecode(response.body);
    return jsonList.cast<Map<String, dynamic>>();
  }

  Future<void> clearHistory(int userId) async {
    final response = await http.delete(Uri.parse("$baseUrl/history/$userId"));
    _handleError(response, 'vidage historique');
  }

  // --- Statistiques ---

  Future<Map<String, dynamic>> getStats(int userId) async {
    final response = await http.get(Uri.parse("$baseUrl/stats/$userId"));
    _handleError(response, 'récupération statistiques');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}
