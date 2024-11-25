import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/bottom_tab/bottom_tab_screen.dart';
import 'package:flutter_hotel_booking_ver2/widgets/app_constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class BookingRefund extends ConsumerStatefulWidget {
  final String bookingId;
  final String paymentIntentId; // Add PaymentIntentId for refund processing
  final String amount; // Add amount for refund calculation

  const BookingRefund({
    Key? key,
    required this.bookingId,
    required this.paymentIntentId,
    required this.amount,
  }) : super(key: key);

  @override
  ConsumerState<BookingRefund> createState() => _BookingRefundState();
}

class _BookingRefundState extends ConsumerState<BookingRefund> {
  final List<String> reasons = [
    "Lịch trình thay đổi",
    "Phòng không đáp ứng yêu cầu",
    "Đã tìm được nơi ở khác",
    "Khác",
  ];
  String? selectedReason;

  Future<void> refundPayment(String paymentIntentId, String amount) async {
    try {
      Map<String, dynamic> body = {
        'payment_intent': paymentIntentId,
        'amount': calculateAmount(amount),
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/refunds'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('Refund successful: ${response.body}');
      } else {
        print('Failed to refund: ${response.body}');
      }
    } catch (err) {
      print('Error while refunding: ${err.toString()}');
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (double.parse(amount)).toInt();
    return calculatedAmount.toString();
  }

  Future<void> cancelBooking(BuildContext context) async {
    if (selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn lý do hủy đặt phòng.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Update Firestore booking
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'bookingStatus': 'cancelled',
        'cancellationReason': selectedReason,
      });

      // Perform refund
      await refundPayment(widget.paymentIntentId, widget.amount);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt phòng đã được hủy và hoàn tiền thành công.'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to the desired screen after successful cancellation
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (context) =>
                BottomTabScreen()), // Replace with the actual bookings list or dashboard screen
        (route) =>
            false, // Clear the back stack to prevent returning to previous screens
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Có lỗi xảy ra: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hủy Đặt Phòng'),
        backgroundColor: Colors.redAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lý do hủy đặt phòng:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: reasons.length,
                itemBuilder: (context, index) {
                  final reason = reasons[index];
                  return RadioListTile<String>(
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                    title: Text(reason),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => cancelBooking(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 28,
                  ),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Xác Nhận Hủy',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
