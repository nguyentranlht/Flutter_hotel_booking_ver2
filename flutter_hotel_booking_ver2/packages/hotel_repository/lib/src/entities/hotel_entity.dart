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
}
