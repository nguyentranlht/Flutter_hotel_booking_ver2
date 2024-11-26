import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Hotel extends Equatable {
  final String hotelId;
  final String hotelName;
  String? imagePath;
  final double starRating;
  final LatLng location;
  final double dist;
  final String hotelAddress;
  final String description; // Sửa lại từ 'descrition'
  final String perNight;
  Offset? screenMapPin;
  bool isSelected;
  final double distanceFromCenter;
  final String userId;

  Hotel({
    required this.hotelId,
    required this.hotelName,
    this.imagePath,
    required this.dist,
    required this.starRating,
    required this.location,
    required this.hotelAddress,
    required this.description, // Sửa lại từ 'descrition'
    required this.perNight,
    required this.isSelected,
    required this.distanceFromCenter,
    required this.userId,
  });

  // Add an empty static method or constant
  static Hotel empty() {
    return Hotel(
      hotelId: '',
      hotelName: 'No Hotel Found',
      imagePath: null,
      starRating: 0.0,
      location: LatLng(0.0, 0.0),
      dist: 0.0,
      hotelAddress: '',
      description: 'No description available',
      perNight: '0',
      isSelected: false,
      distanceFromCenter: 0.0,
      userId: '',
    );
  }

  // Định nghĩa phương thức fromFirestore
  factory Hotel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() as Map<String, dynamic>;
    GeoPoint geoPoint =
        data['location'] ?? GeoPoint(0, 0); // Lấy GeoPoint từ Firestore
    LatLng location = LatLng(geoPoint.latitude,
        geoPoint.longitude); // Chuyển đổi GeoPoint thành LatLng
    return Hotel(
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      imagePath: data['imagePath'],
      dist: data['dist'],
      starRating: (data['starRating'] ?? 0.0).toDouble(),
      location: location, // Sử dụng fromMap của Location
      hotelAddress: data['hotelAddress'] ?? '',
      description: data['description'] ?? '', // Sửa lại từ 'descrition'
      perNight: data['perNight'] ?? '',
      isSelected: data['isSelected'],
      distanceFromCenter: (data['distanceFromCenter'] is int)
          ? (data['distanceFromCenter'] as int)
              .toDouble() // Convert int to double
          : (data['distanceFromCenter'] as double? ?? 0.0), // Use 0.0 if null
      userId: data['userId'],
    );
  }
  // Chuyển Hotel thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'hotelName': hotelName,
      'imagePath': imagePath,
      'starRating': starRating,
      'location': {
        'latitude': location.latitude,
        'longitude': location.longitude,
      },
      'dist': dist,
      'hotelAddress': hotelAddress,
      'description': description,
      'perNight': perNight,
      'isSelected': isSelected,
      'distanceFromCenter': distanceFromCenter,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [
        hotelId,
        hotelName,
        imagePath,
        dist,
        starRating,
        location,
        hotelAddress,
        description,
        perNight,
        isSelected,
        distanceFromCenter,
        userId,
      ];
}
