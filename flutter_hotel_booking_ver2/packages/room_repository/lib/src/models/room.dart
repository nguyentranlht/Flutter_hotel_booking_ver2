import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../entities/entities.dart';
import 'models.dart';

class Room {
  final String roomId;
  final String roomName;
  final String hotelId;
  String? imagePath;
  final String roomType;
  final double pricePerNight;
  final int capacity;
  final bool roomStatus;

  Room({
    required this.roomId,
    required this.roomName,
    required this.hotelId,
    this.imagePath,
    required this.roomType,
    required this.pricePerNight,
    required this.capacity,
    required this.roomStatus,
  });

  static var empty = Room(
    roomId: '',
    roomName: '',
    hotelId: '',
    imagePath: '',
    roomType: '',
    pricePerNight: 0.0,
    capacity: 0,
    roomStatus: false,
  );

  RoomEntity toEntity() {
    return RoomEntity(
      roomId: roomId,
      roomName: roomName,
      hotelId: hotelId,
      imagePath: imagePath,
      roomType: roomType,
      pricePerNight: pricePerNight,
      capacity: capacity,
      roomStatus: roomStatus,
    );
  }

  static Room fromEntity(RoomEntity entity) {
    return Room(
      roomId: entity.roomId,
      roomName: entity.roomName,
      hotelId: entity.hotelId,
      imagePath: entity.imagePath,
      roomType: entity.roomType,
      pricePerNight: entity.pricePerNight,
      capacity: entity.capacity,
      roomStatus: entity.roomStatus,
    );
  }

  // peopleSleeps: $peopleSleeps,
  @override
  String toString() {
    return '''
    roomId: $roomId,
    roomName: $roomName,
    hotelId: $hotelId,
    imagePath: $imagePath,
    roomType: $roomType,
    pricePerNight: $pricePerNight,
    capacity: $capacity,
    roomStatus: $roomStatus,
    ''';
  }
}
