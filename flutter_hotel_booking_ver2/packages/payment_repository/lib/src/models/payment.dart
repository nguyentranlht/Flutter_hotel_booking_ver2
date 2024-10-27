import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

class Payment extends Equatable {
  final String paymentId;
  final String bookingId;
  final double totalPrice;
  final DateTime paymentDate;
  final String paymentMethod;

  Payment({
    required this.paymentId,
    required this.bookingId,
    required this.totalPrice,
    required this.paymentDate,
    required this.paymentMethod,
  });

  static final empty = Payment(
    paymentId: '',
    bookingId: '',
    totalPrice: 0.0,
    paymentDate: DateTime(1970, 1, 1),
    paymentMethod: '',
  );

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == Payment.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != Payment.empty;

  PaymentEntity toEntity() {
    return PaymentEntity(
      paymentId: paymentId,
      bookingId: bookingId,
      totalPrice: totalPrice,
      paymentDate: paymentDate,
      paymentMethod: paymentMethod,
    );
  }

  static Payment fromEntity(PaymentEntity entity) {
    return Payment(
      paymentId: entity.paymentId,
      bookingId: entity.bookingId,
      totalPrice: entity.totalPrice,
      paymentDate: entity.paymentDate,
      paymentMethod: entity.paymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        paymentId,
        bookingId,
        totalPrice,
        paymentDate,
        paymentMethod,
      ];

  @override
  String toString() {
    return '''Payment: {
      paymentId: $paymentId,
      bookingId: $bookingId,
      totalPrice: $totalPrice,
      paymentDate: $paymentDate,
      paymentMethod: $paymentMethod,
    }''';
  }
}
