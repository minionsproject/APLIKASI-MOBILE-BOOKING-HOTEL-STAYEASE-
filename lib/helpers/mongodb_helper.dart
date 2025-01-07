import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'package:stay_ease/models/hotel.dart';
import 'package:stay_ease/models/booking.dart';
import 'package:stay_ease/models/user.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'dart:convert';

class MongoDBHelper {
  static final MongoDBHelper _instance = MongoDBHelper._internal();
  static mongo.Db? _db;

  // Mengambil URL dari environment variable
  String get _mongoUrl => dotenv.env['MONGODB_URL'] ?? '';

  factory MongoDBHelper() => _instance;
  MongoDBHelper._internal();

  // Hash password menggunakan SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = crypto.sha256.convert(bytes);
    return digest.toString();
  }

  Future<mongo.Db> get database async {
    if (_db != null) return _db!;
    try {
      print('Connecting to MongoDB Atlas...');
      _db = await _initDatabase();
      print('MongoDB Atlas connected successfully');
      return _db!;
    } catch (e) {
      print('MongoDB Atlas connection error: $e');
      print('Please check:');
      print('1. Internet connection is active');
      print('2. Username and password are correct');
      print('3. IP address is whitelisted in MongoDB Atlas');
      rethrow;
    }
  }

  // Fungsi untuk login
  Future<User> authenticateUser(String email, String password) async {
    try {
      final db = await database;
      final usersCollection = db.collection('users');

      final hashedPassword = _hashPassword(password);

      final userData = await usersCollection.findOne(
          mongo.where.eq('email', email).eq('password', hashedPassword));

      if (userData == null) {
        throw Exception('Email atau password salah');
      }

      return User.fromMap(userData);
    } catch (e) {
      print('Authentication error: $e');
      rethrow;
    }
  }

  // Fungsi untuk register
  Future<User> registerUser(
      String email, String password, String username) async {
    try {
      final db = await database;
      final usersCollection = db.collection('users');

      // Cek apakah email sudah terdaftar
      final existingUser =
          await usersCollection.findOne(mongo.where.eq('email', email));
      if (existingUser != null) {
        throw Exception('Email sudah terdaftar');
      }

      // Cek apakah username sudah digunakan
      final existingUsername =
          await usersCollection.findOne(mongo.where.eq('username', username));
      if (existingUsername != null) {
        throw Exception('Username sudah digunakan');
      }

      final hashedPassword = _hashPassword(password);
      final now = DateTime.now();

      final user = {
        '_id': mongo.ObjectId(),
        'username': username,
        'email': email,
        'password': hashedPassword,
        'createdAt': now,
        'updatedAt': now,
      };

      await usersCollection.insert(user);
      return User.fromMap(user);
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    }
  }

  Future<mongo.Db> _initDatabase() async {
    try {
      print(
          'MongoDB URL: ${_mongoUrl.replaceAll(RegExp(r':[^:@]+@'), ':****@')}');
      print('Creating MongoDB connection...');

      final db = await mongo.Db.create(_mongoUrl);
      await db.open();
      print('MongoDB opened successfully');

      // Verifikasi koneksi
      final serverStatus = await db.serverStatus();
      print('Server version: ${serverStatus['version']}');
      print('Server connection: ${serverStatus['connections']}');

      // Verifikasi database
      final databaseName = db.databaseName;
      print('Connected to database: $databaseName');

      // Verifikasi dan inisialisasi collections
      final collections = await db.getCollectionNames();
      print('Available collections: $collections');

      // Inisialisasi collections yang diperlukan
      if (!collections.contains('users')) {
        print('Creating users collection...');
        await db.createCollection('users');
      }

      if (!collections.contains('bookings')) {
        print('Creating bookings collection...');
        await db.createCollection('bookings');
        // Buat index untuk userId
        await db.collection('bookings').createIndex(keys: {'userId': 1});
      }

      if (!collections.contains('hotels')) {
        print('Creating hotels collection...');
        await db.createCollection('hotels');
        await _initializeHotelsData(db);
      }

      if (!collections.contains('favorites')) {
        print('Creating favorites collection...');
        await db.createCollection('favorites');
        // Buat index untuk userId dan hotelId
        await db.collection('favorites').createIndex(keys: {
          'userId': 1,
          'hotelId': 1,
        }, unique: true);
      }

      print('All collections initialized successfully');
      return db;
    } catch (e, stackTrace) {
      print('MongoDB initialization error: $e');
      print('Stack trace: $stackTrace');
      if (e.toString().contains('authentication failed')) {
        print('\nAuthentication error:');
        print('1. Periksa username dan password');
        print('2. Pastikan user memiliki akses ke database');
      } else if (e.toString().contains('connection failed')) {
        print('\nConnection error:');
        print('1. Periksa koneksi internet');
        print('2. Pastikan IP address sudah di whitelist di MongoDB Atlas');
        print('3. Periksa firewall tidak memblokir koneksi');
      }
      rethrow;
    }
  }

  Future<void> _initializeHotelsData(mongo.Db db) async {
    final hotelsCollection = db.collection('hotels');

    final initialHotels = [
      {
        '_id': '1',
        'name': 'Blue Garden Boutique Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
        'images': [
          'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80'
        ],
        'rating': 4.8,
        'price': 1500000,
        'reviewCount': 128,
        'description':
            'Hotel mewah dengan pemandangan pantai yang menakjubkan.',
        'address': 'Jl. MH Thamrin No.1, Jepara',
        'facilities': ['WiFi', 'Kolam Renang', 'Spa', 'Restoran', 'Gym']
      },
      {
        '_id': '2',
        'name': 'DSeason Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80',
        'images': [
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?auto=format&fit=crop&w=800&q=80'
        ],
        'rating': 4.9,
        'price': 2500000,
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
        '_id': '3',
        'name': 'Garden House Jepara',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
        'images': [
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?auto=format&fit=crop&w=800&q=80'
        ],
        'rating': 4.7,
        'price': 800000,
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
      },
      {
        '_id': '4',
        'name': 'Palm Beach Resort',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80',
        'images': [
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1549294413-26f195471c9b?auto=format&fit=crop&w=800&q=80'
        ],
        'rating': 4.6,
        'price': 1200000,
        'reviewCount': 150,
        'description':
            'Resort tepi pantai dengan suasana tropis yang menenangkan.',
        'address': 'Jl. Pantai Kartini No. 12, Jepara',
        'facilities': [
          'Pantai Pribadi',
          'Kolam Renang',
          'Restoran',
          'Spa',
          'Water Sports'
        ]
      },
      {
        '_id': '5',
        'name': 'Grand Jepara Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=800&q=80',
        'images': [
          'https://images.unsplash.com/photo-1564501049412-61c2a3083791?auto=format&fit=crop&w=800&q=80',
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=800&q=80'
        ],
        'rating': 4.5,
        'price': 950000,
        'reviewCount': 200,
        'description': 'Hotel bisnis dengan lokasi strategis di pusat kota.',
        'address': 'Jl. Raya Jepara No. 45, Jepara',
        'facilities': [
          'Business Center',
          'Meeting Room',
          'WiFi',
          'Restoran',
          'Fitness Center'
        ]
      },
      {
        '_id': '6',
        'name': 'Sunrise Beach Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
        'images': [
          'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4',
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7'
        ],
        'rating': 4.4,
        'price': 750000,
        'reviewCount': 165,
        'description':
            'Hotel nyaman dengan pemandangan matahari terbit yang indah.',
        'address': 'Jl. Pantai Bandengan Km. 4, Jepara',
        'facilities': [
          'Balkon Pribadi',
          'Restoran',
          'WiFi',
          'Taman',
          'Parkir Gratis'
        ]
      },
      {
        '_id': '7',
        'name': 'Jepara Indah Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa',
        'images': [
          'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa',
          'https://images.unsplash.com/photo-1566073771259-6a8506099945'
        ],
        'rating': 4.3,
        'price': 600000,
        'reviewCount': 140,
        'description':
            'Hotel budget dengan pelayanan ramah dan lokasi strategis.',
        'address': 'Jl. Pemuda No. 23, Jepara',
        'facilities': [
          'WiFi',
          'Restoran',
          'Laundry',
          'Parkir',
          '24-Hour Front Desk'
        ]
      },
      {
        '_id': '8',
        'name': 'Ocean View Resort',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://images.unsplash.com/photo-1582719508461-905c673771fd',
        'images': [
          'https://images.unsplash.com/photo-1582719508461-905c673771fd',
          'https://images.unsplash.com/photo-1571896349842-33c89424de2d'
        ],
        'rating': 4.7,
        'price': 1800000,
        'reviewCount': 220,
        'description': 'Resort mewah dengan pemandangan laut 360 derajat.',
        'address': 'Jl. Pantai Kartini No. 88, Jepara',
        'facilities': [
          'Private Beach',
          'Infinity Pool',
          'Spa',
          'Fine Dining',
          'Water Sports'
        ]
      },
      {
        '_id': '9',
        'name': 'Jepara Heritage Hotel',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl':
            'https://image10e028bd69f7s.unsplash.com/photo-1584132967334-',
        'images': [
          'https://images.unsplash.com/photo-1584132967334-10e028bd69f7',
          'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9'
        ],
        'rating': 4.6,
        'price': 1100000,
        'reviewCount': 175,
        'description': 'Hotel bergaya kolonial dengan sentuhan budaya Jepara.',
        'address': 'Jl. Sultan Hadlirin No. 15, Jepara',
        'facilities': [
          'Galeri Seni',
          'Restoran Tradisional',
          'Spa',
          'Taman',
          'Perpustakaan'
        ]
      },
      {
        '_id': '10',
        'name': 'Green Valley Resort',
        'location': 'Jepara, Jawa Tengah',
        'imageUrl': 'https://images.unsplash.com/photo-1549294413-26f195471c9b',
        'images': [
          'https://images.unsplash.com/photo-1549294413-26f195471c9b',
          'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb'
        ],
        'rating': 4.7,
        'price': 1300000,
        'reviewCount': 190,
        'description': 'Resort di pegunungan dengan suasana sejuk dan asri.',
        'address': 'Jl. Raya Mayong Km. 5, Jepara',
        'facilities': [
          'Taman Botani',
          'Kolam Renang',
          'Restoran Organik',
          'Spa',
          'Hiking Trail'
        ]
      }
    ];

    print('Adding initial hotels data...');
    for (var hotel in initialHotels) {
      await hotelsCollection.insert(hotel);
    }
    print('Initial hotels data added successfully');
  }

  // CRUD untuk Hotel
  Future<void> insertHotel(Hotel hotel) async {
    final db = await database;
    await db.collection('hotels').insert(hotel.toMap());
  }

  Future<List<Hotel>> getHotels() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db
          .collection('hotels')
          .find()
          .map((doc) => {
                ...doc,
                'imageUrl': _getHotelImage(doc['_id'].toString()),
                'images': _getHotelDetailImages(doc['_id'].toString()),
              })
          .toList();

      return results.map((doc) => Hotel.fromMap(doc)).toList();
    } catch (e) {
      print('Error getting hotels: $e');
      rethrow;
    }
  }

  String _getHotelImage(String id) {
    // Mapping ID hotel ke gambar lokal
    final imageMap = {
      '1': 'assets/images/hotel1.jpg',
      '2': 'assets/images/hotel2.jpg',
      '3': 'assets/images/hotel3.jpg',
      '4': 'assets/images/hotel4.jpg',
      '5': 'assets/images/hotel5.jpg',
      '6': 'assets/images/hotel6.jpg',
      '7': 'assets/images/hotel7.jpg',
      '8': 'assets/images/hotel8.jpg',
      '9': 'assets/images/hotel9.jpg',
      '10': 'assets/images/hotel10.jpg',
    };
    return imageMap[id] ?? 'assets/images/placeholder.jpg';
  }

  List<String> _getHotelDetailImages(String id) {
    return [
      'assets/images/hotel${id}_1.jpg',
      'assets/images/hotel${id}_2.jpg',
      'assets/images/hotel${id}_3.jpg',
    ];
  }

  // CRUD untuk Booking
  Future<void> insertBooking(Booking booking) async {
    try {
      final db = await database;
      final bookingsCollection = db.collection('bookings');

      // Konversi data booking ke format yang benar
      final bookingData = {
        '_id': mongo.ObjectId.fromHexString(booking.id),
        'userId': booking.userId,
        'hotelId': booking.hotelId,
        'hotelName': booking.hotelName,
        'hotelLocation': booking.hotelLocation,
        'checkInDate': booking.checkInDate.toIso8601String(),
        'checkOutDate': booking.checkOutDate.toIso8601String(),
        'totalPrice': booking.totalPrice,
        'status': booking.status,
        'createdAt': booking.createdAt.toIso8601String(),
      };

      print('Inserting booking data: $bookingData');
      await bookingsCollection.insert(bookingData);
      print('Booking inserted successfully with ID: ${booking.id}');
    } catch (e) {
      print('Error inserting booking: $e');
      rethrow;
    }
  }

  Future<List<Booking>> getBookingsByUser(String userId) async {
    try {
      final db = await database;
      final bookingsCollection = db.collection('bookings');
      print('Fetching bookings for user: $userId');
      final List<Map<String, dynamic>> bookings = await bookingsCollection
          .find(mongo.where.eq('userId', userId))
          .toList();
      print('Found ${bookings.length} bookings');
      return bookings.map((booking) => Booking.fromMap(booking)).toList();
    } catch (e) {
      print('Error getting bookings: $e');
      rethrow;
    }
  }

  // Operasi Favorit
  Future<void> toggleFavorite(String userId, String hotelId) async {
    final db = await database;
    final exist = await db
        .collection('favorites')
        .findOne(mongo.where.eq('userId', userId).eq('hotelId', hotelId));

    if (exist == null) {
      await db.collection('favorites').insert({
        'userId': userId,
        'hotelId': hotelId,
      });
    } else {
      await db
          .collection('favorites')
          .remove(mongo.where.eq('userId', userId).eq('hotelId', hotelId));
    }
  }

  Future<List<Hotel>> getFavoriteHotels(String userId) async {
    final db = await database;
    final pipeline = mongo.AggregationPipelineBuilder()
        .addStage(mongo.Match(mongo.where.eq('userId', userId)))
        .addStage(mongo.Lookup(
          from: 'hotels',
          localField: 'hotelId',
          foreignField: '_id',
          as: 'hotel',
        ))
        .addStage(mongo.Unwind(mongo.Field('hotel')))
        .build();

    final List<Map<String, dynamic>> results =
        await db.collection('favorites').aggregateToStream(pipeline).toList();

    return results.map((result) => Hotel.fromMap(result['hotel'])).toList();
  }
}
