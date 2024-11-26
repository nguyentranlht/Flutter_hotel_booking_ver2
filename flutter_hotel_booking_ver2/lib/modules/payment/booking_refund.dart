import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/bottom_tab/bottom_tab_screen.dart';
import 'package:flutter_hotel_booking_ver2/widgets/app_constant.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class BookingRefund extends ConsumerStatefulWidget {
  final String bookingId;
  final String paymentIntentId;
  final String amount;
  final DateTime
      checkInDate; // Thêm ngày nhận phòng để tính toán phần trăm hoàn tiền

  const BookingRefund({
    Key? key,
    required this.bookingId,
    required this.paymentIntentId,
    required this.amount,
    required this.checkInDate,
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

  String calculateRefundPercentage() {
    final now = DateTime.now();
    final daysDifference = widget.checkInDate.difference(now).inDays;

    if (daysDifference > 7) {
      return "100% (Hoàn tiền đầy đủ)";
    } else if (daysDifference >= 3) {
      return "50% (Hoàn tiền 50%)";
    } else if (daysDifference >= 1) {
      return "20% (Hoàn tiền 20%)";
    } else {
      return "0% (Không hoàn tiền)";
    }
  }

  Future<void> refundPayment(String paymentIntentId, String amount) async {
    try {
      final percentage = calculateRefundPercentage();
      int refundAmount = 0;

      if (percentage.contains("100%")) {
        refundAmount = int.parse(amount);
      } else if (percentage.contains("50%")) {
        refundAmount = (int.parse(amount) * 0.5).toInt();
      } else if (percentage.contains("20%")) {
        refundAmount = (int.parse(amount) * 0.2).toInt();
      }

      if (refundAmount > 0) {
        Map<String, dynamic> body = {
          'payment_intent': paymentIntentId,
          'amount': refundAmount.toString(),
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
      } else {
        print('No refund due to terms of cancellation.');
      }
    } catch (err) {
      print('Error while refunding: ${err.toString()}');
    }
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
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId)
          .update({
        'bookingStatus': 'cancelled',
        'cancellationReason': selectedReason,
      });

      await refundPayment(widget.paymentIntentId, widget.amount);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt phòng đã được hủy.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => BottomTabScreen()),
        (route) => false,
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
    final refundPercentage = calculateRefundPercentage();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hủy Đặt Phòng',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vui lòng chọn lý do hủy đặt phòng:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reasons.length,
              itemBuilder: (context, index) {
                final reason = reasons[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RadioListTile<String>(
                    value: reason,
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                    title: Text(
                      reason,
                      style: const TextStyle(fontSize: 16),
                    ),
                    activeColor: Colors.redAccent,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Điều khoản hủy phòng:",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "- Trước 7 ngày: Hoàn tiền 100%.\n"
                    "- Từ 3 đến 7 ngày: Hoàn tiền 50%.\n"
                    "- Từ 1 đến 3 ngày: Hoàn tiền 20%.\n"
                    "- Trong vòng 1 ngày: Không hoàn tiền.",
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Số tiền hoàn lại: $refundPercentage",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () => cancelBooking(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 50,
                  ),
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Xác Nhận Hủy',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
