import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/review_data_view.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewsListScreen extends ConsumerStatefulWidget {
  final String hotelId;

  const ReviewsListScreen({Key? key, required this.hotelId}) : super(key: key);

  @override
  ConsumerState<ReviewsListScreen> createState() => _ReviewsListScreenState();
}

class _ReviewsListScreenState extends ConsumerState<ReviewsListScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    debugPrint("HotelId passed to ReviewsListScreen: ${widget.hotelId}");
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch reviews using the provider
    final reviewsAsyncValue = ref.watch(reviewsProvider(widget.hotelId));
    // Fetch the total reviews count
    final reviewsCountAsync = ref.watch(reviewsCountProvider(widget.hotelId));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Đánh Giá Khách Sạn"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: reviewsAsyncValue.when(
        data: (reviewsList) {
          if (reviewsList.isEmpty) {
            return const Center(
              child: Text(
                "Hiện chưa có đánh giá nào.",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display total reviews count
              reviewsCountAsync.when(
                data: (count) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Tổng số lần đánh giá: $count",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Đang tải số lần đánh giá...",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                error: (error, _) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Không thể tải tổng số đánh giá.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    top: 8,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                  ),
                  itemCount: reviewsList.length,
                  itemBuilder: (context, index) {
                    return ReviewsView(
                      callback: () {},
                      reviewsList: reviewsList[index],
                      animation: AlwaysStoppedAnimation<double>(1.0),
                      animationController: animationController,
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          debugPrint("Error fetching reviews: $error");
          debugPrint("Stack trace: $stackTrace");

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Có lỗi xảy ra khi tải đánh giá.",
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
