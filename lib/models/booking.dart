import 'package:mongo_dart/mongo_dart.dart' as mongo;

class Booking {
  final String id;
  final String userId;
  final String hotelId;
  final String hotelName;
  final String hotelLocation;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int totalPrice;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.hotelName,
    required this.hotelLocation,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['_id'].toString(),
      userId: map['userId'],
      hotelId: map['hotelId'],
      hotelName: map['hotelName'],
      hotelLocation: map['hotelLocation'],
      checkInDate: DateTime.parse(map['checkInDate']),
      checkOutDate: DateTime.parse(map['checkOutDate']),
      totalPrice: map['totalPrice'],
      status: map['status'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': mongo.ObjectId.fromHexString(id),
      'userId': userId,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'hotelLocation': hotelLocation,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
