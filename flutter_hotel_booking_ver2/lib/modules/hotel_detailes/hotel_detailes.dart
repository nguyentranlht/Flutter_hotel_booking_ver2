import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hotel_booking_ver2/constants/helper.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/review_data_view.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_button.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:intl/intl.dart';
import '../../provider/favorite_provider.dart';
import 'hotel_roome_list.dart';
import 'rating_view.dart';

class HotelDetailes extends ConsumerStatefulWidget {
  final Hotel hotelData;

  const HotelDetailes({Key? key, required this.hotelData}) : super(key: key);
  @override
  ConsumerState<HotelDetailes> createState() => _HotelDetailesState();
}

class _HotelDetailesState extends ConsumerState<HotelDetailes>
    with TickerProviderStateMixin {
  final oCcy = NumberFormat("#,##0", "vi_VN");
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  var hoteltext1 =
      "Featuring a fitness center, Grand Royale Park Hote is located in Sweden, 4.7 km frome National Museum...";
  var hoteltext2 =
      "Featuring a fitness center, Grand Royale Park Hote is located in Sweden, 4.7 km frome National Museum a fitness center, Grand Royale Park Hote is located in Sweden, 4.7 km frome National Museum a fitness center, Grand Royale Park Hote is located in Sweden, 4.7 km frome National Museum";
  bool isFav = false;
  bool isReadless = false;
  late AnimationController animationController;
  var imageHieght = 0.0;
  late AnimationController _animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    animationController.forward();
    scrollController.addListener(() {
      if (mounted) {
        if (scrollController.offset < 0) {
          // we static set the just below half scrolling values
          _animationController.animateTo(0.0);
        } else if (scrollController.offset > 0.0 &&
            scrollController.offset < imageHieght) {
          // we need around half scrolling values
          if (scrollController.offset < ((imageHieght / 1.2))) {
            _animationController
                .animateTo((scrollController.offset / imageHieght));
          } else {
            // we static set the just above half scrolling values "around == 0.22"
            _animationController.animateTo((imageHieght / 1.2) / imageHieght);
          }
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    imageHieght = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          CommonCard(
            radius: 0,
            color: AppTheme.scaffoldBackgroundColor,
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.only(top: 24 + imageHieght),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  // Hotel title and animation view
                  child: getHotelDetails(isInList: true),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Divider(
                    height: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          Loc.alized.summary,
                          style: TextStyles(context).getBoldStyle().copyWith(
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 4, bottom: 8),
                  child: RichText(
                    textAlign: TextAlign.justify,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: !isReadless ? hoteltext1 : hoteltext2,
                          style: TextStyles(context)
                              .getDescriptionStyle()
                              .copyWith(
                                fontSize: 14,
                              ),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(
                          text: !isReadless
                              ? Loc.alized.read_more
                              : Loc.alized.less,
                          style: TextStyles(context).getRegularStyle().copyWith(
                              color: AppTheme.primaryColor, fontSize: 14),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              setState(() {
                                isReadless = !isReadless;
                              });
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 8,
                    bottom: 16,
                  ),
                  // overall rating view
                  child: RatingView(hotelData: widget.hotelData),
                ),
                _getPhotoReviewUi(Loc.alized.room_photo, Loc.alized.view_all,
                    Icons.arrow_forward, () {}),

                // Hotel inside photo view
                const HotelRoomeList(),
                _getPhotoReviewUi(Loc.alized.reviews, Loc.alized.view_all,
                    Icons.arrow_forward, () {
                  NavigationServices(context)
                      .gotoReviewsListScreen(widget.hotelData.hotelId);

                  print('Hotel ID: ${widget.hotelData.hotelId}');
                }),

                // Feedback & Review data view
                Consumer(
                  builder: (context, ref, child) {
                    final reviewsAsync =
                        ref.watch(reviewsProvider(widget.hotelData.hotelId));

                    return reviewsAsync.when(
                      data: (reviewsList) {
                        if (reviewsList.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              "Hiện chưa có đánh giá nào.",
                              style: TextStyles(context).getBoldStyle(),
                            ),
                          );
                        }

                        // Chỉ hiển thị tối đa 2 review
                        final limitedReviews = reviewsList.take(2).toList();

                        return Column(
                          children: limitedReviews.map((review) {
                            return ReviewsView(
                              reviewsList: review,
                              animation: animationController,
                              animationController: animationController,
                              callback: () {},
                            );
                          }).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (error, stackTrace) {
                        debugPrint("Error fetching reviews: $error");
                        debugPrint("Stack trace: $stackTrace");
                        return Center(
                          child: Text(
                            "Có lỗi xảy ra khi tải đánh giá:\n$error",
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        );
                      },
                    );
                  },
                ),

                const SizedBox(
                  height: 16,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: widget.hotelData.location,
                          zoom: 17,
                        ),
                        mapType: MapType.normal,
                        mapToolbarEnabled: false,
                        compassEnabled: false,
                        myLocationButtonEnabled: false,
                        rotateGesturesEnabled: false,
                        tiltGesturesEnabled: false,
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                        onMapCreated: (GoogleMapController controller) async {
                          // _mapController = controller;
                          // await _mapController?.setMapStyle(
                          //   await DefaultAssetBundle.of(context).loadString(
                          //     AppTheme.isLightMode
                          //         ? "assets/json/mapstyle_light.json"
                          //         : "assets/json/mapstyle_dark.json",
                          //   ),
                          // );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 34, right: 10),
                      child: CommonCard(
                        color: AppTheme.primaryColor,
                        radius: 36,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(
                            FontAwesomeIcons.mapPin,
                            color: Theme.of(context).colorScheme.background,
                            size: 28,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, bottom: 16, top: 16),
                  child: CommonButton(
                    buttonText: Loc.alized.book_now,
                    onTap: () {
                      NavigationServices(context).gotoRoomBookingScreen(
                          widget.hotelData.hotelName,
                          widget.hotelData.hotelId,
                          widget.hotelData.hotelAddress,
                          startDate.toString().substring(0, 10),
                          endDate.toString().substring(0, 10));
                    },
                  ),
                ),

                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),

          // backgrouund image and Hotel name and thier details and more details animation view
          _backgraoundImageUI(widget.hotelData),

          // Arrow back Ui
          Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: SizedBox(
              height: AppBar().preferredSize.height,
              child: Row(
                children: <Widget>[
                  _getAppBarUi(Theme.of(context).disabledColor.withOpacity(0.4),
                      Icons.arrow_back, AppTheme.backgroundColor, () {
                    if (scrollController.offset != 0.0) {
                      scrollController.animateTo(0.0,
                          duration: const Duration(milliseconds: 480),
                          curve: Curves.easeInOutQuad);
                    } else {
                      Navigator.pop(context);
                    }
                  }),
                  const Expanded(
                    child: SizedBox(),
                  ),
                  // like and unlike view
                  _getFavoriteAppBarUi(context, ref, widget.hotelData.hotelId),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _getFavoriteAppBarUi(
      BuildContext context, WidgetRef ref, String hotelId) {
    final favoriteHotelIdsAsync = ref.watch(favoriteHotelIdsProvider);

    return favoriteHotelIdsAsync.when(
      data: (favoriteHotelIds) {
        final isFavorite = favoriteHotelIds.contains(hotelId);
        return _getAppBarUi(
          Theme.of(context).colorScheme.background, // Màu nền của nút
          isFavorite ? Icons.favorite : Icons.favorite_border, // Icon
          Theme.of(context).primaryColor, // Màu biểu tượng
          () {
            ref.read(favoriteServiceProvider).toggleFavoriteHotel(hotelId);
          },
        );
      },
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Icon(Icons.error, color: Colors.red),
    );
  }

  Widget _getAppBarUi(
      Color color, IconData icon, Color iconcolor, VoidCallback onTap) {
    return SizedBox(
      height: AppBar().preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Container(
          width: AppBar().preferredSize.height - 8,
          height: AppBar().preferredSize.height - 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(
                Radius.circular(32.0),
              ),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(icon, color: iconcolor),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getPhotoReviewUi(
      String title, String view, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              title,
              style: TextStyles(context).getBoldStyle().copyWith(
                    fontSize: 14,
                  ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: <Widget>[
                    Text(
                      view,
                      textAlign: TextAlign.left,
                      style: TextStyles(context).getBoldStyle().copyWith(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                    SizedBox(
                      height: 38,
                      width: 26,
                      child: Icon(
                        icon,
                        //Icons.arrow_forward,
                        size: 18,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _backgraoundImageUI(Hotel hotelData) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          var opacity = 1.0 -
              (_animationController.value >= ((imageHieght / 1.2) / imageHieght)
                  ? 1.0
                  : _animationController.value);
          return SizedBox(
            height: imageHieght * (1.0 - _animationController.value),
            child: Stack(
              children: <Widget>[
                IgnorePointer(
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        top: 0,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Image.network(
                            hotelData.imagePath.toString(),
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                  child: Text('Failed to load image'));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: opacity,
                    child: Column(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.only(left: 24, right: 24),
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                color: Colors.black12,
                                padding: const EdgeInsets.all(4.0),
                                child: Column(
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16, right: 16, top: 8),
                                      child: getHotelDetails(),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          bottom: 16,
                                          top: 16),
                                      child: CommonButton(
                                          buttonText: Loc.alized.book_now,
                                          onTap: () {
                                            // Navigation logic here
                                            NavigationServices(context)
                                                .gotoRoomBookingScreen(
                                                    hotelData.hotelName,
                                                    hotelData.hotelId,
                                                    hotelData.hotelAddress,
                                                    startDate
                                                        .toString()
                                                        .substring(0, 10),
                                                    endDate
                                                        .toString()
                                                        .substring(0, 10));
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: ClipRRect(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(24)),
                            child: BackdropFilter(
                              filter:
                                  ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                              child: Container(
                                color: Colors.black12,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    splashColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.2),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(38)),
                                    onTap: () {
                                      try {
                                        scrollController.animateTo(
                                            MediaQuery.of(context).size.height -
                                                MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    5,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.fastOutSlowIn);
                                      } catch (_) {}
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16,
                                          right: 16,
                                          top: 4,
                                          bottom: 4),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Text(
                                            Loc.alized.more_details,
                                            style: TextStyles(context)
                                                .getBoldStyle()
                                                .copyWith(
                                                  color: Colors.white,
                                                ),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.only(top: 2),
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white,
                                              size: 24,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getHotelDetails({bool isInList = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.hotelData.hotelName,
                textAlign: TextAlign.left,
                style: TextStyles(context).getBoldStyle().copyWith(
                      fontSize: 22,
                      color: isInList ? AppTheme.fontcolor : Colors.white,
                    ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    FontAwesomeIcons.locationDot,
                    size: 12,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text(
                    widget.hotelData.dist.toStringAsFixed(1),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyles(context).getRegularStyle().copyWith(
                          fontSize: 14,
                          color: isInList
                              ? Theme.of(context).disabledColor.withOpacity(0.5)
                              : Colors.white,
                        ),
                  ),
                  Expanded(
                    child: Text(
                      Loc.alized.km_to_city,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles(context).getRegularStyle().copyWith(
                            fontSize: 14,
                            color: isInList
                                ? Theme.of(context)
                                    .disabledColor
                                    .withOpacity(0.5)
                                : Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
              isInList
                  ? const SizedBox()
                  : Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: <Widget>[
                          Helper.ratingStar(),
                          Text(
                            " ${widget.hotelData.starRating}",
                            style:
                                TextStyles(context).getRegularStyle().copyWith(
                                      fontSize: 14,
                                      color: isInList
                                          ? Theme.of(context)
                                              .disabledColor
                                              .withOpacity(0.5)
                                          : Colors.white,
                                    ),
                          ),
                          // Text(
                          //   Loc.alized.reviews,
                          //   style:
                          //       TextStyles(context).getRegularStyle().copyWith(
                          //             fontSize: 14,
                          //             color: isInList
                          //                 ? Theme.of(context).disabledColor
                          //                 : Colors.white,
                          //           ),
                          // ),
                        ],
                      ),
                    ),
            ],
          ),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              "${(oCcy.format(num.parse(widget.hotelData.perNight)))}₫",
              textAlign: TextAlign.left,
              style: TextStyles(context).getBoldStyle().copyWith(
                    fontSize: 22,
                    color: isInList
                        ? Theme.of(context).textTheme.bodyLarge!.color
                        : Colors.white,
                  ),
            ),
            Text(
              Loc.alized.per_night,
              style: TextStyles(context).getRegularStyle().copyWith(
                    fontSize: 14,
                    color: isInList
                        ? Theme.of(context).disabledColor
                        : Colors.white,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
