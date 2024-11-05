import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String bookingId;
  final String userId;
  final String roomId;
  final DateTime bookingDate;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String bookingStatus;
  final String paymentStatus;
  final double totalPrice;

  Booking(
      {required this.bookingId,
      required this.userId,
      required this.roomId,
      required this.bookingDate,
      required this.checkInDate,
      required this.checkOutDate,
      required this.bookingStatus,
      required this.paymentStatus,
      required this.totalPrice});

  @override
  List<Object?> get props => [
        bookingId,
        userId,
        roomId,
        bookingDate,
        checkInDate,
        checkOutDate,
        bookingStatus,
        paymentStatus,
        totalPrice
      ];
}
