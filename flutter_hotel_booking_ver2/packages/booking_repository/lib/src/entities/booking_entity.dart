import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BookingEntity extends Equatable {
  final String bookingId;
  final String userId;
  final String roomId;
  final DateTime bookingDate;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String bookingStatus;
  final String paymentStatus;
  final double totalPrice;

  const BookingEntity(
      {required this.bookingId,
      required this.userId,
      required this.roomId,
      required this.bookingDate,
      required this.checkInDate,
      required this.checkOutDate,
      required this.bookingStatus,
      required this.paymentStatus,
      required this.totalPrice});

  Map<String, dynamic> toDocument() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'roomId': roomId,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'checkInDate': Timestamp.fromDate(checkInDate),
      'checkOutDate': Timestamp.fromDate(checkOutDate),
      'bookingStatus': bookingStatus,
      'paymentStatus': paymentStatus,
      'totalPrice': totalPrice, // Chuyển DateTime thành Timestamp
    };
  }

  static BookingEntity fromDocument(Map<String, dynamic> doc) {
    return BookingEntity(
      bookingId: doc['bookingId'] as String,
      userId: doc['userId'] as String,
      roomId: doc['roomId'] as String,
      bookingDate: (doc['bookingDate'] as Timestamp).toDate(),
      checkInDate: (doc['checkInDate'] as Timestamp).toDate(),
      checkOutDate: (doc['checkOutDate'] as Timestamp).toDate(),
      bookingStatus: doc['bookingStatus'] as String,
      paymentStatus: doc['paymentStatus'] as String,
      totalPrice: doc['totalPrice'] as double,
    );
  }

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

  @override
  String toString() {
    return '''BookingEntity: {
      bookingId: $bookingId,
      userId: $userId,
      roomId: $roomId,
      bookingDate: $bookingDate,
      checkInDate: $checkInDate,
      checkOutDate: $checkOutDate,
      bookingStatus: $bookingStatus,
      paymentStatus: $paymentStatus,
      totalPrice: $totalPrice,
    }''';
  }
}
