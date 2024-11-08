import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/hotel_list_view.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_filter_prodiver.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_hotel_booking_ver2/constants/text_styles.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/components/filter_bar_ui.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/components/map_and_list_view.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/components/time_date_view.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_search_bar.dart';
import 'package:flutter_hotel_booking_ver2/widgets/remove_focuse.dart';

class HotelHomeScreen extends StatefulWidget {
  const HotelHomeScreen({Key? key}) : super(key: key);

  @override
  State<HotelHomeScreen> createState() => _HotelHomeScreenState();
}

class _HotelHomeScreenState extends State<HotelHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController _animationController;
  ScrollController scrollController = ScrollController();
  int room = 1;
  int ad = 2;

  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  bool _isShowMap = false;

  final searchBarHieght = 130.0;
  final filterBarHieght = 100.0;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 0), vsync: this);
    scrollController.addListener(() {
      if (scrollController.offset <= 0) {
        _animationController.animateTo(0.0);
      } else if (scrollController.offset > 0.0 &&
          scrollController.offset < searchBarHieght) {
        _animationController
            .animateTo((scrollController.offset / searchBarHieght));
      } else {
        _animationController.animateTo(1.0);
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
    return Scaffold(
      body: Stack(
        children: <Widget>[
          RemoveFocuse(
            onClick: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Column(
              children: <Widget>[
                _getAppBarUI(),
                _isShowMap
                    ? Consumer(
                        builder: (context, ref, _) {
                          final hotelListAsync = ref.watch(hotelProvider);

                          return hotelListAsync.when(
                            data: (hotelList) => MapAndListView(
                              hotelList: hotelList,
                              searchBarUI: _getSearchBarUI(),
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Center(
                              child: Text('Error loading hotels: $error'),
                            ),
                          );
                        },
                      )
                    : Expanded(
                        child: Consumer(
                          builder: (context, ref, _) {
                            final hotelListAsync =
                                ref.watch(filteredHotelProvider);

                            return hotelListAsync.when(
                              data: (hotelList) => Stack(
                                children: <Widget>[
                                  Container(
                                    color: AppTheme.scaffoldBackgroundColor,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: hotelList.length,
                                      padding: const EdgeInsets.only(
                                        top: 8 + 158 + 52.0,
                                      ),
                                      scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        var count = hotelList.length > 10
                                            ? 10
                                            : hotelList.length;
                                        var animation = Tween(
                                          begin: 0.0,
                                          end: 1.0,
                                        ).animate(
                                          CurvedAnimation(
                                            parent: animationController,
                                            curve: Interval(
                                              (1 / count) * index,
                                              1.0,
                                              curve: Curves.fastOutSlowIn,
                                            ),
                                          ),
                                        );
                                        animationController.forward();
                                        return HotelListView(
                                          callback: () {
                                            NavigationServices(
                                                    context)
                                                .gotoRoomBookingScreen(
                                                    hotelList[index].hotelName,
                                                    hotelList[index].hotelId,
                                                    hotelList[index]
                                                        .hotelAddress,
                                                    startDate
                                                        .toString()
                                                        .substring(0, 10),
                                                    endDate
                                                        .toString()
                                                        .substring(0, 10));
                                          },
                                          hotelData: hotelList[index],
                                          animation: animation,
                                          animationController:
                                              animationController,
                                        );
                                      },
                                    ),
                                  ),
                                  AnimatedBuilder(
                                    animation: _animationController,
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return Positioned(
                                        top: -searchBarHieght *
                                            (_animationController.value),
                                        left: 0,
                                        right: 0,
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              color: Theme.of(context)
                                                  .scaffoldBackgroundColor,
                                              child: Column(
                                                children: <Widget>[
                                                  _getSearchBarUI(),
                                                  const FilterBarUI(),
                                                ],
                                              ),
                                            ),
                                            TimeDateView(
                                              startDate: startDate,
                                              endDate: endDate,
                                              onStartDateChanged:
                                                  (newStartDate) {
                                                setState(() {
                                                  startDate = newStartDate;
                                                });
                                              },
                                              onEndDateChanged: (newEndDate) {
                                                setState(() {
                                                  endDate = newEndDate;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              loading: () => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              error: (error, stack) => Center(
                                child: Text('Error loading hotels: $error'),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getSearchBarUI() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.only(right: 8, top: 8, bottom: 8, left: 8),
              child: CommonCard(
                color: AppTheme.backgroundColor,
                radius: 36,
                child: const CommonSearchBar(
                  enabled: true,
                  ishsow: false,
                  text: "Hồ Chí Minh...",
                ),
              ),
            ),
          ),
          CommonCard(
            color: AppTheme.primaryColor,
            radius: 36,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  NavigationServices(context).gotoSearchScreen();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Icon(FontAwesomeIcons.magnifyingGlass,
                      size: 20, color: AppTheme.backgroundColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getAppBarUI() {
    return Padding(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top, left: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            alignment: Get.find<Loc>().isRTL
                ? Alignment.centerRight
                : Alignment.centerLeft,
            width: AppBar().preferredSize.height + 40,
            height: AppBar().preferredSize.height,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: const BorderRadius.all(
                  Radius.circular(32.0),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.arrow_back),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                Loc.alized.explore,
                style: TextStyles(context).getTitleStyle(),
              ),
            ),
          ),
          SizedBox(
            width: AppBar().preferredSize.height + 40,
            height: AppBar().preferredSize.height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(32.0),
                    ),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.favorite_border),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(32.0),
                    ),
                    onTap: () {
                      setState(() {
                        _isShowMap = !_isShowMap;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(_isShowMap
                          ? Icons.sort
                          : FontAwesomeIcons.mapLocationDot),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
