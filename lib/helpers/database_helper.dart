import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:stay_ease/models/booking.dart';
import 'package:stay_ease/models/hotel.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'stay_ease.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    // Tabel Hotel
    await db.execute('''
      CREATE TABLE hotels(
        id TEXT PRIMARY KEY,
        name TEXT,
        location TEXT,
        imageUrl TEXT,
        images TEXT,
        rating REAL,
        price REAL,
        reviewCount INTEGER,
        description TEXT,
        address TEXT,
        facilities TEXT
      )
    ''');

    // Tabel Booking
    await db.execute('''
      CREATE TABLE bookings(
        id TEXT PRIMARY KEY,
        hotelId TEXT,
        userId TEXT,
        checkIn TEXT,
        checkOut TEXT,
        guests INTEGER,
        totalPrice REAL,
        status TEXT,
        paymentMethod TEXT,
        paymentStatus TEXT,
        createdAt TEXT,
        FOREIGN KEY (hotelId) REFERENCES hotels (id)
      )
    ''');

    // Tabel Favorit
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT,
        hotelId TEXT,
        FOREIGN KEY (hotelId) REFERENCES hotels (id)
      )
    ''');
  }

  // CRUD untuk Hotel
  Future<void> insertHotel(Hotel hotel) async {
    final db = await database;
    await db.insert(
      'hotels',
      hotel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Hotel>> getHotels() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('hotels');
    return List.generate(maps.length, (i) => Hotel.fromMap(maps[i]));
  }

  // CRUD untuk Booking
  Future<void> insertBooking(Booking booking) async {
    final db = await database;
    await db.insert(
      'bookings',
      booking.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Booking>> getBookingsByUser(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookings',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return List.generate(maps.length, (i) => Booking.fromMap(maps[i]));
  }

  // Operasi Favorit
  Future<void> toggleFavorite(String userId, String hotelId) async {
    final db = await database;
    final exist = await db.query(
      'favorites',
      where: 'userId = ? AND hotelId = ?',
      whereArgs: [userId, hotelId],
    );

    if (exist.isEmpty) {
      await db.insert('favorites', {
        'userId': userId,
        'hotelId': hotelId,
      });
    } else {
      await db.delete(
        'favorites',
        where: 'userId = ? AND hotelId = ?',
        whereArgs: [userId, hotelId],
      );
    }
  }

  Future<List<Hotel>> getFavoriteHotels(String userId) async {
    final db = await database;
    return db.rawQuery('''
      SELECT h.*
      FROM hotels h
      INNER JOIN favorites f ON h.id = f.hotelId
      WHERE f.userId = ?
    ''', [
      userId
    ]).then(
        (maps) => List.generate(maps.length, (i) => Hotel.fromMap(maps[i])));
  }
}
