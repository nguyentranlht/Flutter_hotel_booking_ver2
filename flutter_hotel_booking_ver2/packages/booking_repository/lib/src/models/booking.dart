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
  final String paymentIntentId;
  final String fullname;
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
    required this.paymentIntentId,
    required this.fullname,
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
        paymentIntentId,
        fullname,
      ];
  Booking copyWith({
    String? bookingId,
    String? userId,
    String? hotelId,
    String? roomId,
    DateTime? bookingDate,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? bookingStatus,
    String? paymentStatus,
    String? totalPrice,
    int? numberOfGuests,
    String? paymentIntentId,
    String? fullname,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      hotelId: hotelId ?? this.hotelId,
      roomId: roomId ?? this.roomId,
      bookingDate: bookingDate ?? this.bookingDate,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      paymentIntentId: paymentIntentId ?? this.paymentIntentId,
      fullname: fullname ?? this.fullname,
    );
  }

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
      paymentIntentId: data['paymentIntentId'],
      fullname: data['fullname'],
    );
  }
}
