import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String roomId;
  final String roomName;
  final String hotelId;
  String? imagePath;
  final String roomType;
  final String pricePerNight;
  final int capacity;
  final bool roomStatus;
  final int maxPeople;
  final List<Map<String, String>>
      availableDates; // Sử dụng List<Map<String, String>>

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
    required this.availableDates,
  });

  // Phương thức fromFirestore để chuyển đổi dữ liệu từ Firebase thành Room
  factory Room.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    // Chuyển đổi availableDates từ Firestore thành List<Map<String, String>>
    List<Map<String, String>> availableDates = [];
    if (data['availableDates'] != null) {
      availableDates = List<Map<String, String>>.from(
        (data['availableDates'] as List).map((date) => {
              'start': date['start'] as String,
              'end': date['end'] as String,
            }),
      );
    }

    return Room(
      roomId: doc.id,
      roomName: data['roomName'] ?? '',
      hotelId: data['hotelId'] ?? '',
      imagePath: data['imagePath'],
      roomType: data['roomType'] ?? '',
      pricePerNight: data['pricePerNight'] ?? '',
      capacity: data['capacity'] ?? 0,
      roomStatus: data['roomStatus'] ?? false,
      maxPeople: data['maxPeople'] ?? 0,
      availableDates: availableDates,
    );
  }

  // Phương thức toFirestore để chuyển đổi Room thành dữ liệu để lưu trữ trong Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'roomName': roomName,
      'hotelId': hotelId,
      'imagePath': imagePath,
      'roomType': roomType,
      'pricePerNight': pricePerNight,
      'capacity': capacity,
      'roomStatus': roomStatus,
      'maxPeople': maxPeople,
      'availableDates': availableDates,
    };
  }
}
