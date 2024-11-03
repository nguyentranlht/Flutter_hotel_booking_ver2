// services/room_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:room_repository/room_repository.dart';

// services/room_service.dart
class RoomService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Room>> streamRoomsByHotelId(String hotelId) {
    try {
      return _firestore
          .collection('rooms')
          .where('hotelId', isEqualTo: hotelId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Room.fromFirestore(doc)).toList());
    } catch (e) {
      throw Exception("Failed to fetch hotels: $e");
    }
  }
}
