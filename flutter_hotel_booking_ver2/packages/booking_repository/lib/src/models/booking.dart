import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String bookingId;
  final String userId;
  final String hotelId;
  final String roomId;
  final DateTime bookingDate;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String bookingStatus;
  final String paymentStatus;
  final String totalPrice;
  final int numberOfGuests;

  Booking({
    required this.bookingId,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.bookingDate,
    required this.checkInDate,
    required this.checkOutDate,
    required this.bookingStatus,
    required this.paymentStatus,
    required this.totalPrice,
    required this.numberOfGuests,
  });

  @override
  List<Object?> get props => [
        bookingId,
        userId,
        hotelId,
        roomId,
        bookingDate,
        checkInDate,
        checkOutDate,
        bookingStatus,
        paymentStatus,
        totalPrice,
        numberOfGuests,
      ];

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      bookingId: doc.id,
      userId: data['userId'],
      hotelId: data['hotelId'],
      roomId: data['roomId'],
      bookingDate: (data['bookingDate'] as Timestamp).toDate(),
      checkInDate: (data['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (data['checkOutDate'] as Timestamp).toDate(),
      numberOfGuests: data['numberOfGuests'],
      bookingStatus: data['bookingStatus'],
      totalPrice: data['totalPrice'],
      paymentStatus: data['paymentStatus'],
    );
  }
}
