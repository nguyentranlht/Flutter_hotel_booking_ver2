import 'package:booking_repository/booking_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final bookingProvider = StreamProvider<List<Booking>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    return Stream.value(
        []); // Trả về một stream rỗng nếu người dùng chưa đăng nhập
  }
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('bookings')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Booking.fromFirestore(doc)).toList());
});

final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final asyncBookings = ref.watch(bookingProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return asyncBookings.whenData((bookings) {
        return bookings.where((booking) {
          final checkInDate = DateTime(
            booking.checkInDate.year,
            booking.checkInDate.month,
            booking.checkInDate.day,
          );

          // Include bookings that are either on or after today
          return checkInDate.isAtSameMomentAs(today) ||
              checkInDate.isAfter(today);
        }).toList();
      }).value ??
      [];
});

final finishedBookingsProvider = Provider<List<Booking>>((ref) {
  final asyncBookings = ref.watch(bookingProvider);
  final now = DateTime.now();

  // Sử dụng whenData để lọc và trả về danh sách booking
  return asyncBookings.whenData((bookings) {
        return bookings
            .where((booking) => booking.checkOutDate.isBefore(now))
            .toList();
      }).value ??
      [];
});
