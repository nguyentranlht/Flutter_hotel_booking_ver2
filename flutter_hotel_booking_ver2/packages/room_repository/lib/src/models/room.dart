import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String roomId;
  final String roomName;
  final String hotelId;
  String? imagePath;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final bool roomStatus;
  final int maxPeople;

  Room({
    required this.roomId,
    required this.roomName,
    required this.hotelId,
    this.imagePath,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.roomStatus,
    required this.maxPeople,
  });
  // Phương thức fromFirestore để chuyển đổi dữ liệu từ Firebase thành Room
  factory Room.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Room(
      roomId: doc.id,
      roomName: data['roomName'] ?? '',
      hotelId: data['hotelId'] ?? '',
      imagePath: data['imagePath'],
      roomType: data['roomType'] ?? '',
      pricePerNight: (data['pricePerNight'] ?? 0.0).toDouble(),
      capacity: data['capacity'] ?? 0,
      roomStatus: data['roomStatus'] ?? false,
      maxPeople: data['maxPeople'] ?? 0,
    );
  }
}
