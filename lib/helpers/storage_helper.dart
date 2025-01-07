import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stay_ease/models/hotel.dart';
import 'package:stay_ease/models/booking.dart';

class StorageHelper {
  static final StorageHelper _instance = StorageHelper._internal();
  static SharedPreferences? _prefs;

  factory StorageHelper() => _instance;
  StorageHelper._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Inisialisasi data awal jika belum ada
    if (!_prefs!.containsKey('hotels')) {
      await _initializeHotelsData();
    }
  }

  Future<void> _initializeHotelsData() async {
    final initialHotels = [
      {
        'id': '1',
        'name': 'Blue Garden Boutique Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl': 'https://picsum.photos/800/600?random=1',
        'images': [
          'https://picsum.photos/800/600?random=1',
          'https://picsum.photos/800/600?random=2'
        ],
        'rating': 4.8,
        'price': 1500000.0,
        'reviewCount': 128,
        'description':
            'Hotel mewah dengan pemandangan pantai yang menakjubkan.',
        'address': 'Jl. MH Thamrin No.1, Jepara',
        'facilities': ['WiFi', 'Kolam Renang', 'Spa', 'Restoran', 'Gym']
      },
      {
        'id': '2',
        'name': 'DSeason Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl': 'https://picsum.photos/800/600?random=3',
        'images': [
          'https://picsum.photos/800/600?random=3',
          'https://picsum.photos/800/600?random=4'
        ],
        'rating': 4.9,
        'price': 2500000.0,
        'reviewCount': 256,
        'description':
            'Resort mewah dengan pantai pribadi dan pemandangan laut.',
        'address': 'Jl. Pariwisata 09 Bandengan, 59432 Jepara, Indonesia',
        'facilities': [
          'Pantai Pribadi',
          'Spa',
          'Restoran',
          'Bar',
          'Kolam Renang Infinity'
        ]
      },
      {
        'id': '3',
        'name': 'Garden House Jepara',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl': 'https://picsum.photos/800/600?random=5',
        'images': [
          'https://picsum.photos/800/600?random=5',
          'https://picsum.photos/800/600?random=6'
        ],
        'rating': 4.7,
        'price': 800000.0,
        'reviewCount': 180,
        'description': 'Hotel syariah modern dengan fasilitas lengkap.',
        'address':
            'Jl Lucca No 3 RT 08 RW 03 Bandengan, 59432 Jepara, Indonesia',
        'facilities': [
          'Mushola',
          'Restoran Halal',
          'Meeting Room',
          'WiFi',
          'Kolam Renang Terpisah'
        ]
      }
    ];

    await _prefs!.setString('hotels', jsonEncode(initialHotels));
  }

  // CRUD untuk Hotel
  Future<void> saveHotel(Hotel hotel) async {
    final hotels = await getHotels();
    hotels.add(hotel);
    await _prefs!
        .setString('hotels', jsonEncode(hotels.map((h) => h.toMap()).toList()));
  }

  Future<List<Hotel>> getHotels() async {
    try {
      final hotelsJson = _prefs!.getString('hotels') ?? '[]';
      final List<dynamic> hotelsMap = jsonDecode(hotelsJson);
      return hotelsMap.map((map) => Hotel.fromMap(map)).toList();
    } catch (e) {
      print('Error getting hotels: $e');
      return [];
    }
  }

  // CRUD untuk Booking
  Future<void> saveBooking(Booking booking) async {
    final bookings = await getBookings();
    bookings.add(booking);
    await _prefs!.setString(
        'bookings', jsonEncode(bookings.map((b) => b.toMap()).toList()));
  }

  Future<List<Booking>> getBookings() async {
    final bookingsJson = _prefs!.getString('bookings') ?? '[]';
    final List<dynamic> bookingsMap = jsonDecode(bookingsJson);
    return bookingsMap.map((map) => Booking.fromMap(map)).toList();
  }

  Future<List<Booking>> getBookingsByUser(String userId) async {
    final bookings = await getBookings();
    return bookings.where((booking) => booking.userId == userId).toList();
  }

  // Operasi Favorit
  Future<void> toggleFavorite(String userId, String hotelId) async {
    final favorites = await getFavorites(userId);
    if (favorites.contains(hotelId)) {
      favorites.remove(hotelId);
    } else {
      favorites.add(hotelId);
    }
    await _prefs!.setStringList('favorites_$userId', favorites);
  }

  Future<List<String>> getFavorites(String userId) async {
    return _prefs!.getStringList('favorites_$userId') ?? [];
  }
}
