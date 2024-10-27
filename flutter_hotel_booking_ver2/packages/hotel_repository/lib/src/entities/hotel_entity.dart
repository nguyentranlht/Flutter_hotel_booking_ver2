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

  HotelEntity({
    required this.hotelId,
    required this.hotelName,
    this.imagePath,
    required this.starRating,
    required this.location,
    required this.hotelAddress,
    required this.descrition,
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
    );
  }
}
