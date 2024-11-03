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

  Map<String, Object?> toDocument() {
    return {
      'hotelId': hotelId,
      'hotelName': hotelName,
      'imagePath': imagePath,
      'starRating': starRating,
      'location': GeoPoint(location.latitude, location.longitude),
      'dist': dist,
      'hotelAddress': hotelAddress,
      'descrition': descrition,
      'perNight': perNight,
      'isSelected': isSelected,
    };
  }

  // Define the fromFirestore method here
  factory HotelEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    GeoPoint geoPoint = data['location'] ?? GeoPoint(0, 0); // Lấy GeoPoint từ Firestore
    LatLng location = LatLng(geoPoint.latitude, geoPoint.longitude); // Chuyển đổi GeoPoint thành LatLng
    return HotelEntity(
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      imagePath: data['imagePath'],
      starRating: (data['starRating'] ?? 0.0).toDouble(),
      location:location, // Assuming Location has a fromMap method
      dist: data['dist'],
      hotelAddress: data['hotelAddress'] ?? '',
      descrition: data['description'] ?? '',
      perNight: data['perNight'] ?? '',
      isSelected: data['isSelected']??'',
    );
  }

  // You can also add a method to convert HotelEntity to Firestore format if needed
  Map<String, dynamic> toFirestore() {
    return {
      'hotelId': hotelId,
      'hotelName': hotelName,
      'imagePath': imagePath,
      'starRating': starRating,
      'location': location, // Assuming Location has a toMap method
      'dist': dist,
      'hotelAddress': hotelAddress,
      'description': descrition,
      'perNight': perNight,
      'isSelected': isSelected,
    };
  }

  static HotelEntity fromDocument(Map<String, dynamic> doc) {
    GeoPoint geoPoint = doc['location'];
    LatLng location = LatLng(geoPoint.latitude, geoPoint.longitude);
    
    return HotelEntity(
      hotelId: doc['hotelId'],
      hotelName: doc['hotelName'],
      imagePath: doc['imagePath'],
      starRating: doc['starRating'],
      location: location,
      dist: doc['dist'],
      hotelAddress: doc['hotelAddress'],
      descrition: doc['descrition'],
      perNight: doc['perNight'],
      isSelected: doc['isSelected'],
    );
  }
}
