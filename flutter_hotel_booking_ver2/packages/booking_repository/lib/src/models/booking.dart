import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

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

  /// Empty user which represents an unauthenticated user.
  static final empty = Booking(
    bookingId: '',
    userId: '',
    roomId: '',
    bookingDate: DateTime(1970, 1, 1),
    checkInDate: DateTime(1970, 1, 1),
    checkOutDate: DateTime(1970, 1, 1),
    bookingStatus: '',
    paymentStatus: '',
    totalPrice: 0.0,
  );

  /// Modify MyUser parameters
  Booking copyWith({
    String? bookingId,
    String? userId,
    String? roomId,
    DateTime? bookingDate,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    String? bookingStatus,
    String? paymentStatus,
    double? totalPrice,
  }) {
    return Booking(
      bookingId: bookingId ?? this.bookingId,
      userId: userId ?? this.userId,
      roomId: roomId ?? this.roomId,
      bookingDate: bookingDate ?? this.bookingDate,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == Booking.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != Booking.empty;

  /// Chuyển MyUser thành MyUserEntity để lưu trữ
  BookingEntity toEntity() {
    return BookingEntity(
      bookingId: bookingId,
      userId: userId,
      roomId: roomId,
      bookingDate: bookingDate,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      bookingStatus: bookingStatus,
      paymentStatus: paymentStatus,
      totalPrice: totalPrice,
    );
  }

  /// Tạo MyUser từ MyUserEntity khi đọc từ Firestore
  static Booking fromEntity(BookingEntity entity) {
    return Booking(
      bookingId: entity.bookingId,
      userId: entity.userId,
      roomId: entity.roomId,
      bookingDate: entity.bookingDate,
      checkInDate: entity.checkInDate,
      checkOutDate: entity.checkOutDate,
      bookingStatus: entity.bookingStatus,
      paymentStatus: entity.paymentStatus,
      totalPrice: entity.totalPrice,
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
}
