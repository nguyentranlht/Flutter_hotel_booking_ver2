import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_repository/src/entities/location_entity.dart';
import 'package:hotel_repository/src/models/location.dart';

class HotelEntity {
  final String hotelId;
  final String hotelName;
  String? imagePath;
  final double starRating;
  final Location location;
  final String hotelAddress;
  final String descrition;
  final String perNight;

  HotelEntity({
    required this.hotelId,
    required this.hotelName,
    this.imagePath,
    required this.starRating,
    required this.location,
    required this.hotelAddress,
    required this.descrition,
    required this.perNight,
  });

  Map<String, Object?> toDocument() {
    return {
      'hotelId': hotelId,
      'hotelName': hotelName,
      'imagePath': imagePath,
      'starRating': starRating,
      'location': location.toEntity().toDocument(),
      'hotelAddress': hotelAddress,
      'descrition': descrition,
      'perNight': perNight,
    };
  }

  // Define the fromFirestore method here
  factory HotelEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HotelEntity(
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      imagePath: data['imagePath'],
      starRating: (data['starRating'] ?? 0.0).toDouble(),
      location: Location.fromEntity(data['location'].fromDocument(
          doc['location'])), // Assuming Location has a fromMap method
      hotelAddress: data['hotelAddress'] ?? '',
      descrition: data['description'] ?? '',
      perNight: data['perNight'] ?? '',
    );
  }

  // You can also add a method to convert HotelEntity to Firestore format if needed
  Map<String, dynamic> toFirestore() {
    return {
      'hotelId': hotelId,
      'hotelName': hotelName,
      'imagePath': imagePath,
      'starRating': starRating,
      'location': location
          .toEntity()
          .toDocument(), // Assuming Location has a toMap method
      'hotelAddress': hotelAddress,
      'description': descrition,
      'perNight': perNight,
    };
  }

  static HotelEntity fromDocument(Map<String, dynamic> doc) {
    return HotelEntity(
      hotelId: doc['hotelId'],
      hotelName: doc['hotelName'],
      imagePath: doc['imagePath'],
      starRating: doc['starRating'],
      location:
          Location.fromEntity(LocationEntity.fromDocument(doc['location'])),
      hotelAddress: doc['hotelAddress'],
      descrition: doc['descrition'],
      perNight: doc['perNight'],
    );
  }
}
