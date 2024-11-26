import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/payment/booking_refund.dart';

class DetailBookingsScreen extends StatelessWidget {
  final String hotelName;
  final String roomType;
  final String pricePerNight;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final String hotelAddress;
  final String bookingId;
  final String paymentIntentId;
  const DetailBookingsScreen({
    Key? key,
    required this.hotelName,
    required this.roomType,
    required this.pricePerNight,
    required this.checkInDate,
    required this.checkOutDate,
    required this.hotelAddress,
    required this.bookingId,
    required this.paymentIntentId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chi Tiết Đặt Phòng',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hotel Name
            Text(
              hotelName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),

            // Hotel Address
            Text(
              'Địa chỉ: $hotelAddress',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black87,
              ),
            ),
            const Divider(height: 30, thickness: 2),

            // Room Type
            Text(
              'Loại phòng:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              roomType,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            // Price Per Night
            Text(
              'Giá mỗi đêm:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              '$pricePerNight VND',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            // Check-in Date
            Text(
              'Ngày nhận phòng:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              checkInDate.toString().substring(0, 10),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            // Check-out Date
            Text(
              'Ngày trả phòng:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              checkOutDate.toString().substring(0, 10),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.normal,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),

            // Divider
            const Divider(height: 30, thickness: 2),

            // Call to Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 28,
                    ),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Quay Lại',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingRefund(
                          bookingId: bookingId,
                          paymentIntentId: paymentIntentId,
                          amount: pricePerNight,
                          checkInDate: checkInDate,
                        ),
                      ),
                    );
                  },
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
                    'Hủy Đặt Phòng',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
