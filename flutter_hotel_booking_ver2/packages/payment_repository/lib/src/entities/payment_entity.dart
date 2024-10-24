class PaymentEntity {
  final String paymentId;
  final String bookingId;
  final double totalPrice;
  final DateTime paymentDate;
  final String paymentMethod;

  PaymentEntity({
    required this.paymentId,
    required this.bookingId,
    required this.totalPrice,
    required this.paymentDate,
    required this.paymentMethod,
  });

  Map<String, Object?> toDocument() {
    return {
      'paymentId': paymentId,
      'bookingId': bookingId,
      'totalPrice': totalPrice,
      'paymentDate': paymentDate,
      'paymentMethod': paymentMethod,
    };
  }

  static PaymentEntity fromDocument(Map<String, dynamic> doc) {
    return PaymentEntity(
      paymentId: doc['paymentId'],
      bookingId: doc['bookingId'],
      totalPrice: doc['totalPrice'],
      paymentDate: doc['paymentDate'],
      paymentMethod: doc['paymentMethod'],
    );
  }
}
