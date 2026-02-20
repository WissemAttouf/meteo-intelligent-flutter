// lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'home_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Villes Favorites'),
      ),
      body: ListView(
        children: [
          _buildFavoriteCityItem(context, 'Paris'),
          _buildFavoriteCityItem(context, 'Lyon'),
          _buildFavoriteCityItem(context, 'Marseille'),
          _buildFavoriteCityItem(context, 'Toulouse'),
          _buildFavoriteCityItem(context, 'Nice'),
        ],
      ),
    );
  }

  Widget _buildFavoriteCityItem(BuildContext context, String city) {
    return ListTile(
      leading: const Icon(Icons.location_city),
      title: Text(city),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () {
          // Action de suppression
        },
      ),
      onTap: () {
        // CORRECTION: Passage de la ville sélectionnée à HomeScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(initialCity: city), // Passage de la ville
          ),
              (route) => false,
        );
      },
    );
  }
}