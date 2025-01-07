import 'package:flutter/material.dart';
import 'package:stay_ease/models/hotel.dart';
import 'package:stay_ease/helpers/mongodb_helper.dart';

class HotelProvider with ChangeNotifier {
  List<Hotel> _hotels = [];
  List<Hotel> _allHotels = [];
  final MongoDBHelper _mongoDBHelper = MongoDBHelper();

  List<Hotel> get hotels => [..._hotels];

  Future<void> loadHotels() async {
    try {
      final hotels = await _mongoDBHelper.getHotels();
      print('Loaded hotels: ${hotels.length}');
      print('Sample hotel data: ${hotels.first.toMap()}');
      _hotels = hotels;
      notifyListeners();
    } catch (e) {
      print('Error loading hotels: $e');
    }
  }

  void searchHotels(String query) {
    if (query.isEmpty) {
      _hotels = [..._allHotels];
      notifyListeners();
      return;
    }

    final searchLower = query.toLowerCase();
    _hotels = _allHotels.where((hotel) {
      return hotel.name.toLowerCase().contains(searchLower) ||
          hotel.location.toLowerCase().contains(searchLower);
    }).toList();
    notifyListeners();
  }
}
