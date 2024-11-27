import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RatingView extends ConsumerWidget {
  final Hotel hotelData;

  const RatingView({Key? key, required this.hotelData}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy danh sách reviews từ Firestore qua provider
    final reviewsAsync = ref.watch(reviewsProvider(hotelData.hotelId));

    return reviewsAsync.when(
      data: (reviewsList) {
        // Tính trung bình rating từ reviews
        double averageRating = 0.0;
        if (reviewsList.isNotEmpty) {
          averageRating = reviewsList
                  .map((review) => review.rating)
                  .reduce((a, b) => a + b) /
              reviewsList.length;
        }

        return CommonCard(
          color: AppTheme.backgroundColor,
          radius: 16,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 60,
                      child: Text(
                        averageRating.toStringAsFixed(1), // Hiển thị trung bình
                        textAlign: TextAlign.left,
                        style: TextStyles(context).getBoldStyle().copyWith(
                              fontSize: 38,
                              color: Theme.of(context).primaryColor,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              Loc.alized.overall_rating,
                              textAlign: TextAlign.left,
                              style: TextStyles(context)
                                  .getRegularStyle()
                                  .copyWith(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .disabledColor
                                        .withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 4),
                getBarUI('room', 95.0, context),
                const SizedBox(height: 4),
                getBarUI('service', 80.0, context),
                const SizedBox(height: 4),
                getBarUI('location', 65.0, context),
                const SizedBox(height: 4),
                getBarUI('price', 85, context),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) {
        debugPrint("Error loading reviews: $error");
        return Center(
          child: Text(
            "Có lỗi xảy ra khi tải đánh giá.",
            style: TextStyle(color: Colors.red, fontSize: 14),
          ),
        );
      },
    );
  }

  Widget getBarUI(String text, double percent, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          width: 60,
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyles(context).getRegularStyle().copyWith(
                  fontSize: 14,
                  color: Theme.of(context).disabledColor.withOpacity(0.8),
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: percent.toInt(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: SizedBox(
                    height: 4,
                    child: CommonCard(
                      color: AppTheme.primaryColor,
                      radius: 8,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 100 - percent.toInt(),
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
