import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:room_repository/room_repository.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Hotel>> fetchHotels() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('hotels').get();
      return snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception("Failed to fetch hotels: $e");
    }
  }

  Stream<List<Room>> streamAvailableRooms(
      String startDate, String endDate, int guests) {
    return _firestore
        .collection('rooms')
        .where('capacity', isGreaterThanOrEqualTo: guests)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final room = Room.fromFirestore(doc);
            // Kiểm tra xem availableDates có phù hợp với thời gian yêu cầu không
            final isAvailable = room.availableDates.any((dateRange) {
              final start = dateRange['start']!;
              final end = dateRange['end']!;
              return end.compareTo(startDate) >= 0 &&
                  start.compareTo(endDate) <= 0;
            });
            return isAvailable ? room : null;
          })
          .whereType<Room>()
          .toList();
    });
  }
}
