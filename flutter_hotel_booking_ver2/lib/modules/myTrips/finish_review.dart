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

  const ReviewScreen({
    Key? key,
    required this.hotel,
    required this.hotelId,
    required this.userId,
    required this.fullname,
  }) : super(key: key);

  Future<void> _submitReview(BuildContext context, WidgetRef ref) async {
    final roomRating = ref.read(roomRatingProvider);
    final serviceRating = ref.read(serviceRatingProvider);
    final locationRating = ref.read(locationRatingProvider);
    final priceRating = ref.read(priceRatingProvider);
    final comments = ref.read(commentsProvider);

    if ([roomRating, serviceRating, locationRating, priceRating].contains(0) ||
        comments.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(isSubmittingProvider.notifier).state = true;

    try {
      final reviewId =
          FirebaseFirestore.instance.collection('reviews').doc().id;

      // Tính điểm trung bình
      final rating =
          ((roomRating + serviceRating + locationRating + priceRating) / 4)
              .toDouble();

      // Dữ liệu đánh giá
      final reviewData = {
        'reviewId': reviewId,
        'userId': userId,
        'hotelId': hotelId,
        'categoryScores': {
          'room': roomRating,
          'service': serviceRating,
          'location': locationRating,
          'price': priceRating,
        },
        'comments': comments.trim(),
        'reviewDate': Timestamp.fromDate(DateTime.now()),
        'fullname': fullname,
        'rating': rating, // Lưu điểm trung bình
        'picture': '',
      };

      // Lưu dữ liệu đánh giá vào Firestore
      await FirebaseFirestore.instance
          .collection('reviews')
          .doc(reviewId)
          .set(reviewData);

      // Cập nhật điểm trung bình tổng quát vào `ratingProvider`
      ref.read(ratingProvider.notifier).state = rating;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Đánh giá của bạn đã được gửi."),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Có lỗi xảy ra: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      ref.read(isSubmittingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roomRating = ref.watch(roomRatingProvider);
    final serviceRating = ref.watch(serviceRatingProvider);
    final locationRating = ref.watch(locationRatingProvider);
    final priceRating = ref.watch(priceRatingProvider);
    final isSubmitting = ref.watch(isSubmittingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh Giá Khách Sạn"),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Đánh giá từng danh mục (1 - 10):",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildSlider(
                  context,
                  title: "Phòng",
                  rating: roomRating,
                  onChanged: (value) => ref
                      .read(roomRatingProvider.notifier)
                      .state = value.toInt(),
                ),
                _buildSlider(
                  context,
                  title: "Dịch vụ",
                  rating: serviceRating,
                  onChanged: (value) => ref
                      .read(serviceRatingProvider.notifier)
                      .state = value.toInt(),
                ),
                _buildSlider(
                  context,
                  title: "Vị trí",
                  rating: locationRating,
                  onChanged: (value) => ref
                      .read(locationRatingProvider.notifier)
                      .state = value.toInt(),
                ),
                _buildSlider(
                  context,
                  title: "Giá cả",
                  rating: priceRating,
                  onChanged: (value) => ref
                      .read(priceRatingProvider.notifier)
                      .state = value.toInt(),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Nhận xét của bạn:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                    NavigationServices(context).gotoHotelDetailes(hotel);
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
        ),
      ),
    );
  }

  Widget _buildSlider(BuildContext context,
      {required String title,
      required int rating,
      required ValueChanged<double> onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Slider(
          value: rating.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          label: "$rating",
          onChanged: onChanged,
        ),
      ],
    );
  }
}
