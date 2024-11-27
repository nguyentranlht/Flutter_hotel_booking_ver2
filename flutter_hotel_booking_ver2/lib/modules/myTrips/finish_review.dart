import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/provider/review_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

class ReviewScreen extends ConsumerWidget {
  final Hotel hotel;
  final String hotelId;
  final String userId;
  final String fullname;
  const ReviewScreen(
      {Key? key,
      required this.hotelId,
      required this.userId,
      required this.hotel,
      required this.fullname})
      : super(key: key);

  Future<void> _submitReview(BuildContext context, WidgetRef ref) async {
    final rating = ref.read(ratingProvider); // Lấy điểm rating từ provider
    final comments = ref.read(commentsProvider); // Lấy nhận xét từ provider

    if (rating == 0 || comments.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(isSubmittingProvider.notifier).state = true; // Trạng thái gửi

    try {
      final reviewId =
          FirebaseFirestore.instance.collection('reviews').doc().id;

      // Tạo dữ liệu đánh giá
      final reviewData = {
        'reviewId': reviewId,
        'userId': userId,
        'hotelId': hotelId,
        'rating': rating,
        'comments': comments.trim(),
        'reviewDate': Timestamp.fromDate(DateTime.now()),
        'picture': '', // Cập nhật sau nếu cần
        'fullname': fullname,
      };

      // Lưu vào Firestore
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .set(reviewData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đánh giá của bạn đã được gửi."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); // Quay lại trang trước
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      ref.read(isSubmittingProvider.notifier).state = false; // Kết thúc gửi
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rating = ref.watch(ratingProvider); // Theo dõi rating
    final isSubmitting =
        ref.watch(isSubmittingProvider); // Theo dõi trạng thái gửi

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh Giá Khách Sạn"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vui lòng đánh giá (Thang điểm 1 - 10):",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Slider chọn thang điểm
            Slider(
              value: rating.toDouble(),
              min: 1,
              max: 10,
              divisions: 9, // Chia khoảng từ 1 đến 10
              label: "$rating",
              onChanged: (value) {
                ref.read(ratingProvider.notifier).state = value.toInt();
              },
            ),
            const SizedBox(height: 16),
            Text(
              "Điểm đánh giá: $rating",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "Nhận xét của bạn:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Nhập nhận xét
            TextField(
              onChanged: (value) =>
                  ref.read(commentsProvider.notifier).state = value,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: "Nhập nhận xét của bạn...",
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed:
                        isSubmitting ? null : () => _submitReview(context, ref),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 32,
                      ),
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Gửi đánh giá",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      NavigationServices(context).gotoHotelDetailes(
                        hotel,
                      ); // Điều hướng đến HotelDetails
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 32,
                      ),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Xem Thông Tin Khách Sạn",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
