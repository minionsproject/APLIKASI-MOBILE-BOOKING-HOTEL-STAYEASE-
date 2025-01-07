import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stay_ease/providers/auth_provider.dart';
import 'package:stay_ease/helpers/storage_helper.dart';
import 'package:stay_ease/models/hotel.dart';
import 'package:stay_ease/widgets/app_drawer.dart';
import 'package:stay_ease/widgets/hotel_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final storage = StorageHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit Saya'),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<List<String>>(
        future: storage.getFavorites(authProvider.userId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favoriteIds = snapshot.data ?? [];

          if (favoriteIds.isEmpty) {
            return const Center(
              child: Text('Belum ada hotel favorit'),
            );
          }

          return FutureBuilder<List<Hotel>>(
            future: storage.getHotels(),
            builder: (context, hotelSnapshot) {
              if (hotelSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final hotels = hotelSnapshot.data ?? [];
              final favoriteHotels = hotels
                  .where((hotel) => favoriteIds.contains(hotel.id))
                  .toList();

              return ListView.builder(
                itemCount: favoriteHotels.length,
                itemBuilder: (ctx, i) => HotelCard(hotel: favoriteHotels[i]),
              );
            },
          );
        },
      ),
    );
  }
}
