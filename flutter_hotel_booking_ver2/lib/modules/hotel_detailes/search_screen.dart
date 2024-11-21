import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_hotel_booking_ver2/constants/themes.dart';
import 'package:flutter_hotel_booking_ver2/language/app_localizations.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_appbar_view.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_card.dart';
import 'package:flutter_hotel_booking_ver2/widgets/common_search_bar.dart';
import 'package:flutter_hotel_booking_ver2/widgets/remove_focuse.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_detailes/search_view.dart';
import '../../models/hotel_list_data.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'search_type_list.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with TickerProviderStateMixin {
  List<HotelListData> lastsSearchesList = HotelListData.lastsSearchesList;

  late AnimationController animationController;
  
  // Lưu trữ từ khóa tìm kiếm
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      body: RemoveFocuse(
        onClick: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CommonAppbarView(
              iconData: Icons.close,
              onBackClick: () {
                Navigator.pop(context);
              },
              titleText: Loc.alized.search_hotel,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 16, bottom: 16),
                      child: CommonCard(
                        color: AppTheme.backgroundColor,
                        radius: 36,
                        child: CommonSearchBar(
                          iconData: FontAwesomeIcons.magnifyingGlass,
                          enabled: true,
                          text: Loc.alized.where_are_you_going,
                          onChanged: (query) {
                            setState(() {
                              searchQuery = query;  // Cập nhật từ khóa tìm kiếm
                            });
                          },
                        ),
                      ),
                    ),
                    const SearchTypeListView(),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 24, right: 24, top: 8),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              Loc.alized.result_search,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(4.0)),
                              onTap: () {
                                setState(() {
                                  searchQuery = "";  // Xóa từ khóa tìm kiếm
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      Loc.alized.clear_all,
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Column(
                        children: getPList(context, ref),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom + 16,
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

  // Hàm lọc danh sách khách sạn theo từ khóa tìm kiếm
List<Widget> getPList(BuildContext context, WidgetRef ref) {
    final hotelListAsync = ref.watch(hotelProvider);

    return hotelListAsync.when(
      data: (hotelList) {
        List<Widget> resultList = [];
        const int columnCount = 2; // Số cột hiển thị
        int counter = 0;

        // Lọc danh sách khách sạn theo từ khóa tìm kiếm
        final filteredHotelList = hotelList.where((hotel) {

        bool matchesSearchQuery = hotel.hotelName.toLowerCase().contains(searchQuery.toLowerCase());
        // bool matchesDistrictQuery = hotel.dist.toLowerCase().contains(districtQuery);
        // bool matchesPriceQuery = hotel.perNight.toString().contains(priceQuery.toLowerCase());
        // bool matchesAddressQuery = hotel.hotelAddress.toLowerCase().contains(searchQuery.toLowerCase());

          return matchesSearchQuery;
        }).toList();

        for (var i = 0; i < (filteredHotelList.length / columnCount).ceil(); i++) {
          List<Widget> rowWidgets = [];
          for (var j = 0; j < columnCount; j++) {
            if (counter < filteredHotelList.length) {
              final hotel = filteredHotelList[counter];
              final animation = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: Interval(
                    (1 / filteredHotelList.length) * counter,
                    1.0,
                    curve: Curves.fastOutSlowIn,
                  ),
                ),
              );
              animationController.forward();
              rowWidgets.add(
                Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Điều hướng tới trang chi tiết khách sạn
                    NavigationServices(context).gotoHotelDetailes(hotel);
                  },
                  child: SerchView(
                    hotelInfo: hotel, // Dữ liệu khách sạn
                    animation: animation,
                    animationController: animationController,
                  ),
                ),
              ),
              );    
              counter++;
            } else {
              rowWidgets.add(const Expanded(child: SizedBox()));
            }
          }

          resultList.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: rowWidgets,
              ),
            ),
          );
        }

        return resultList;
      },
      loading: () => [const Center(child: CircularProgressIndicator())],
      error: (error, stack) => [Center(child: Text('Error: $error'))],
    );
  }
}
