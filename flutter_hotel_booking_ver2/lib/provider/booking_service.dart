import 'package:booking_repository/booking_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách booking theo ID khách sạn
  Stream<List<Booking>> getBookingsByHotel(String hotelId) {
    return _firestore
        .collection('bookings')
        .where('hotelId', isEqualTo: hotelId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Booking.fromFirestore(doc))
            .toList());
  }

  // Cập nhật trạng thái booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'bookingStatus': status,
      });
    } catch (e) {
      throw Exception('Error updating booking status: $e');
    }
  }

  // Xóa booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Error deleting booking: $e');
    }
  }
}