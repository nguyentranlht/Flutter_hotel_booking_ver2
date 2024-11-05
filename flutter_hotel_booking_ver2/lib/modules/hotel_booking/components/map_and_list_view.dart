import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/hotel_booking/components/google_map_ui_view.dart';
import 'package:hotel_repository/hotel_repository.dart';

import '../../../routes/route_names.dart';
import '../map_hotel_view.dart';

class MapAndListView extends StatelessWidget {
  final List<Hotel> hotelList; // Thay đổi kiểu thành List<Hotel>
  final Widget searchBarUI;

  const MapAndListView({
    Key? key,
    required this.hotelList,
    required this.searchBarUI,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));
    return Expanded(
      child: StatefulBuilder(
        builder: (context, state) {
          return Column(
            children: <Widget>[
              searchBarUI,
              // const TimeDateView(),
              Expanded(
                child: Stack(
                  children: <Widget>[
                    GoogleMapUIView(
                      hotelList: hotelList, // Truyền hotelList kiểu List<Hotel>
                    ),
                    IgnorePointer(
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(1.0),
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.4),
                              Theme.of(context)
                                  .scaffoldBackgroundColor
                                  .withOpacity(0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: SizedBox(
                        height: 156,
                        child: ListView.builder(
                          itemCount: hotelList.length,
                          padding: const EdgeInsets.only(
                              top: 8, bottom: 8, right: 16),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return MapHotelListView(
                              callback: () {
                                NavigationServices(context)
                                    .gotoRoomBookingScreen(
                                  hotelList[index].hotelName,
                                  hotelList[index].hotelId,
                                  hotelList[index].hotelAddress,
                                  startDate.toString(),
                                  endDate.toString(),
                                ); // Sử dụng Hotel thay vì HotelListData
                              },
                              hotelData: hotelList[index], // Truyền Hotel vào
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
