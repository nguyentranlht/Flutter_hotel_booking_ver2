import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:room_repository/room_repository.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class RoomeBookView extends ConsumerWidget {
  final Room roomData;
  final AnimationController animationController;
  final Animation<double> animation;
  final String hotelName;
  final String hotelId;
  final String hotelAddress;
  final String startDate;
  final String endDate;

  const RoomeBookView({
    Key? key,
    required this.roomData,
    required this.animationController,
    required this.animation,
    required this.hotelName,
    required this.hotelId,
    required this.hotelAddress,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var pageController = PageController(initialPage: 0);
    final oCcy = NumberFormat("#,##0", "vi_VN");
    List<String> images = roomData.imagePath?.split(" ") ?? [];

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 40 * (1.0 - animation.value), 0.0),
            child: Column(
              children: <Widget>[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: PageView(
                        controller: pageController,
                        pageSnapping: true,
                        scrollDirection: Axis.horizontal,
                        children: images.isNotEmpty
                            ? images.map((image) {
                                return Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                );
                              }).toList()
                            : [Image.asset('assets/images/placeholder.png')],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SmoothPageIndicator(
                        controller: pageController,
                        count: images.length,
                        effect: WormEffect(
                          activeDotColor: Theme.of(context).primaryColor,
                          dotColor: Theme.of(context).colorScheme.background,
                          dotHeight: 10.0,
                          dotWidth: 10.0,
                          spacing: 5.0,
                        ),
                        onDotClicked: (index) {},
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            roomData.roomName,
                            maxLines: 2,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            height: 38,
                            child: ElevatedButton(
                              onPressed: () {
                                DateTime start = DateTime.parse(startDate);
                                DateTime end = DateTime.parse(endDate);

                                int differenceInDays =
                                    end.difference(start).inDays;

                                var perNight =
                                    int.parse(roomData.pricePerNight) *
                                        differenceInDays;

                                NavigationServices(context)
                                    .gotoRoomConfirmationScreen(
                                  hotelName,
                                  hotelId,
                                  hotelAddress,
                                  perNight.toString(),
                                  startDate.toString().substring(0, 10),
                                  endDate.toString().substring(0, 10),
                                  roomData,
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Text(
                                  "Book Now",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "${(oCcy.format(num.parse(roomData.pricePerNight)))}₫",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            Loc.alized.per_night,
                            style:
                                TextStyles(context).getRegularStyle().copyWith(
                                      fontSize: 15,
                                      color: Theme.of(context).dividerColor,
                                    ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Capacity: ${roomData.capacity} people",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 14),
                          ),
                          InkWell(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(4.0)),
                            onTap: () {},
                            child: Row(
                              children: <Widget>[
                                Text(
                                  "More details",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
