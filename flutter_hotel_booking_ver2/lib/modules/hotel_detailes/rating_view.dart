import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:review_repository/review_repository.dart';

class RatingView extends ConsumerWidget {
  final Hotel hotelData;

  const RatingView({Key? key, required this.hotelData}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider(hotelData.hotelId));

    return reviewsAsync.when(
      data: (reviewsList) {
        if (reviewsList.isEmpty) {
          return _buildNoReviews(context);
        }

        final averageScores = _calculateAverageScores(reviewsList);

        return CommonCard(
          color: AppTheme.backgroundColor,
          radius: 16,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildAverageRating(context, averageScores['average']!),
                const Divider(thickness: 1, height: 24),
                _buildCategoryRatings(context, averageScores),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        debugPrint("Error loading reviews: $error");
        return _buildError(context, error);
      },
    );
  }

  Widget _buildNoReviews(BuildContext context) {
    return CommonCard(
      color: AppTheme.backgroundColor,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "Hiện chưa có đánh giá nào.",
            style: TextStyles(context)
                .getRegularStyle()
                .copyWith(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, Object error) {
    return CommonCard(
      color: AppTheme.backgroundColor,
      radius: 16,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            "Có lỗi xảy ra: $error",
            style: TextStyles(context)
                .getRegularStyle()
                .copyWith(color: Colors.red, fontSize: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildAverageRating(BuildContext context, double averageRating) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Text(
            averageRating.toStringAsFixed(1),
            style: TextStyles(context).getBoldStyle().copyWith(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Loc.alized.overall_rating,
                style: TextStyles(context).getRegularStyle().copyWith(
                      fontSize: 14,
                      color: Theme.of(context).disabledColor.withOpacity(0.8),
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star,
                    size: 20,
                    color: index < (averageRating / 2).floor()
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).disabledColor.withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryRatings(
      BuildContext context, Map<String, double> averageScores) {
    return Column(
      children: [
        _buildCategoryBar(context, 'Phòng', averageScores['room']!),
        const SizedBox(height: 12),
        _buildCategoryBar(context, 'Dịch vụ', averageScores['service']!),
        const SizedBox(height: 12),
        _buildCategoryBar(context, 'Vị trí', averageScores['location']!),
        const SizedBox(height: 12),
        _buildCategoryBar(context, 'Giá cả', averageScores['price']!),
      ],
    );
  }

  Widget _buildCategoryBar(
      BuildContext context, String category, double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: TextStyles(context).getRegularStyle().copyWith(
                fontSize: 14,
                color: Theme.of(context).disabledColor.withOpacity(0.8),
              ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: (score * 10).toInt(),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Expanded(
              flex: 100 - (score * 10).toInt(),
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).disabledColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              score.toStringAsFixed(1),
              style: TextStyles(context).getRegularStyle().copyWith(
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Map<String, double> _calculateAverageScores(List<Review> reviews) {
    final totalReviews = reviews.length;
    final totalScores = {
      'room': 0.0,
      'service': 0.0,
      'location': 0.0,
      'price': 0.0,
      'average': 0.0,
    };

    for (final review in reviews) {
      totalScores['room'] =
          (totalScores['room']! + (review.categoryScores['room'] ?? 0));
      totalScores['service'] =
          (totalScores['service']! + (review.categoryScores['service'] ?? 0));
      totalScores['location'] =
          (totalScores['location']! + (review.categoryScores['location'] ?? 0));
      totalScores['price'] =
          (totalScores['price']! + (review.categoryScores['price'] ?? 0));
      totalScores['average'] = totalScores['average']! + review.rating;
    }

    totalScores.updateAll((key, value) => value / totalReviews);
    return totalScores;
  }
}
