import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hotel_repository/src/entities/location_entity.dart';
import 'package:hotel_repository/src/models/location.dart';

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
  });
}
