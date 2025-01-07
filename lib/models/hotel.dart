class Hotel {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final List<String> images;
  final double rating;
  final int price;
  final int reviewCount;
  final String description;
  final String address;
  final List<String> facilities;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.images,
    required this.rating,
    required this.price,
    required this.reviewCount,
    required this.description,
    required this.address,
    required this.facilities,
  });

  factory Hotel.fromMap(Map<String, dynamic> map) {
    return Hotel(
      id: map['_id'].toString(),
      name: map['name'],
      location: map['location'],
      imageUrl: map['imageUrl'],
      images: List<String>.from(map['images']),
      rating: map['rating'].toDouble(),
      price: map['price'],
      reviewCount: map['reviewCount'],
      description: map['description'],
      address: map['address'],
      facilities: List<String>.from(map['facilities']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'location': location,
      'imageUrl': imageUrl,
      'images': images,
      'rating': rating,
      'price': price,
      'reviewCount': reviewCount,
      'description': description,
      'address': address,
      'facilities': facilities,
    };
  }
}
