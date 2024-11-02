import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:hotel_repository/src/models/location.dart';

class Hotel extends Equatable {
  final String hotelId;
  final String hotelName;
  String? imagePath;
  final double starRating;
  final Location location;
  final String hotelAddress;
  final String description; // Sửa lại từ 'descrition'
  final String perNight;

  Hotel({
    required this.hotelId,
    required this.hotelName,
    this.imagePath,
    required this.starRating,
    required this.location,
    required this.hotelAddress,
    required this.description, // Sửa lại từ 'descrition'
    required this.perNight,
  });

  // Định nghĩa phương thức fromFirestore
  factory Hotel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Hotel(
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      imagePath: data['imagePath'],
      starRating: (data['starRating'] ?? 0.0).toDouble(),
      location:
          Location.fromMap(data['location']), // Sử dụng fromMap của Location
      hotelAddress: data['hotelAddress'] ?? '',
      description: data['description'] ?? '', // Sửa lại từ 'descrition'
      perNight: data['perNight'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
        hotelId,
        hotelName,
        imagePath,
        starRating,
        location,
        hotelAddress,
        description,
        perNight,
      ];
}
