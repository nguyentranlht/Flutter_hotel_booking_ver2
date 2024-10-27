import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_repository/room_repository.dart';
import '../models/models.dart';

class RoomEntity {
  final String roomId;
  final String roomName;
  final String hotelId;
  String? imagePath;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final bool roomStatus;

  RoomEntity({
    required this.roomId,
    required this.roomName,
    required this.hotelId,
    this.imagePath,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.roomStatus,
  });

  Map<String, Object?> toDocument() {
    return {
      'roomId': roomId,
      'roomName': roomName,
      'hotelId': hotelId,
      'imagePath': imagePath,
      'roomType': roomType,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'roomStatus': roomStatus,
    };
  }

  static RoomEntity fromDocument(Map<String, dynamic> doc) {
    return RoomEntity(
      roomId: doc["roomId"],
      roomName: doc["roomName"],
      hotelId: doc["hotelId"],
      imagePath: doc["imagePath"],
      roomType: doc["roomType"],
      pricePerNight: doc["pricePerNight"],
      capacity: doc["capacity"],
      roomStatus: doc["roomStatus"],
    );
  }
}
