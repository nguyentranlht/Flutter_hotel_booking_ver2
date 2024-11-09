import 'package:google_maps_flutter/google_maps_flutter.dart';

class HotelEntity {
  final String hotelId;
  final String hotelName;
  String? imagePath;
  final double starRating;
  final LatLng location;
  final double dist;
  final String hotelAddress;
  final String descrition;
  final String perNight;
  final bool isSelected;
  final double distanceFromCenter;

  HotelEntity({
    required this.hotelId,
    required this.hotelName,
    this.imagePath,
    required this.starRating,
    required this.location,
    required this.dist,
    required this.hotelAddress,
    required this.descrition,
    required this.perNight,
    required this.isSelected,
    required this.distanceFromCenter,
  });
}
