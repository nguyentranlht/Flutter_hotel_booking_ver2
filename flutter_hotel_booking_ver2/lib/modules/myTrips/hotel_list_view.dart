import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/helper.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/provider/favorite_provider.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ver2/widgets/list_cell_animation_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:intl/intl.dart';

class HotelListView extends ConsumerWidget {
  final bool isShowDate;
  final VoidCallback callback;
  final Hotel hotelData;
  final AnimationController animationController;
  final Animation<double> animation;

  const HotelListView({
    Key? key,
    required this.hotelData,
    required this.animationController,
    required this.animation,
    required this.callback,
    this.isShowDate = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oCcy = NumberFormat("#,##0", "vi_VN");

    // Watch the user's favorite hotel IDs
    final favoriteHotelIdsAsync = ref.watch(favoriteHotelIdsProvider);

    return ListCellAnimationView(
      animation: animation,
      animationController: animationController,
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 16),
        child: Column(
          children: <Widget>[
            isShowDate
                ? Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ngày check-in', // Adjust as needed based on date requirements
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : const SizedBox(),
            CommonCard(
              color: AppTheme.backgroundColor,
              radius: 16,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                child: Stack(
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        AspectRatio(
                          aspectRatio: 2,
                          child: hotelData.imagePath != null
                              ? Image.network(
                                  hotelData.imagePath!,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  'assets/images/hotel_1.jpg',
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16, top: 8, bottom: 8, right: 8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      hotelData.hotelName,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3.0),
                                          child: Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            hotelData.hotelAddress,
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3.0),
                                          child: Icon(
                                            Icons.accessibility_new,
                                            size: 12,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            "${hotelData.distanceFromCenter} km đến trung tâm",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: <Widget>[
                                          Helper.ratingStar(),
                                          Text(
                                            " ${hotelData.starRating}",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                          const Text(" reviews",
                                              style: TextStyle(fontSize: 14)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  right: 16, top: 8, left: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    "${(oCcy.format(num.parse(hotelData.perNight)))}₫",
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "per night",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Theme.of(context).disabledColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      left: 0,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(16.0),
                          ),
                          onTap: callback,
                        ),
                      ),
                    ),
                    // Favorite icon with condition based on favoriteHotelIds
                    Positioned(
                      top: 8,
                      right: 8,
                      child: favoriteHotelIdsAsync.when(
                        data: (favoriteHotelIds) {
                          final isFavorite =
                              favoriteHotelIds.contains(hotelData.hotelId);
                          return GestureDetector(
                            onTap: () {
                              ref
                                  .read(favoriteServiceProvider)
                                  .toggleFavoriteHotel(hotelData.hotelId);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.background,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(
                                  8.0), // Padding for icon inside the circle
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          );
                        },
                        loading: () => CircularProgressIndicator(),
                        error: (error, stack) =>
                            Icon(Icons.error, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
