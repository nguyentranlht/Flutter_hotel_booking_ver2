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

  Future<void> updateAvailableDates(
    String roomId,
    String startDate,
    String endDate,
  ) async {
    final roomRef = _firestore.collection('rooms').doc(roomId);

    // Use transaction to ensure data consistency
    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(roomRef);

      if (!snapshot.exists) {
        throw Exception("Room not found");
      }

      // Get current availableDates or initialize as empty list if it doesn't exist
      List<dynamic> currentDates = snapshot.data()?['availableDates'] ?? [];

      // Add the new date range to the availableDates list
      currentDates.add({
        'start': startDate,
        'end': endDate,
      });

      // Update the room document with the new availableDates
      transaction.update(roomRef, {'availableDates': currentDates});
    }).catchError((e) {
      throw Exception("Failed to update available dates: $e");
    });
  }

  Stream<List<Room>> streamAvailableRooms(
      String startDate, String endDate, int guests) {
    // Định dạng ngày tháng thành DateTime để so sánh
    final startDateParsed = DateTime.parse(startDate);
    final endDateParsed = DateTime.parse(endDate);

    return _firestore
        .collection('rooms')
        .where('capacity', isGreaterThanOrEqualTo: guests)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) {
            final room = Room.fromFirestore(doc);
            // Kiểm tra availableDates trong room
            final isAvailable = room.availableDates.any((dateRange) {
              final rangeStart = DateTime.parse(dateRange['start']!);
              final rangeEnd = DateTime.parse(dateRange['end']!);

              // So sánh ngày
              return rangeEnd.isAfter(startDateParsed) &&
                  rangeStart.isBefore(endDateParsed);
            });
            return isAvailable ? room : null;
          })
          .whereType<Room>()
          .toList();
    });
  }
}
