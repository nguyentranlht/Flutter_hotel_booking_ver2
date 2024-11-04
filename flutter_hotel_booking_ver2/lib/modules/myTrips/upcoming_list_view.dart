import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/hotel_list_view.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpcomingListView extends StatefulWidget {
  final AnimationController animationController;

  const UpcomingListView({Key? key, required this.animationController})
      : super(key: key);

  @override
  State<UpcomingListView> createState() => _UpcomingListViewState();
}

class _UpcomingListViewState extends State<UpcomingListView> {
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now().add(const Duration(days: 1));
  @override
  void initState() {
    widget.animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final hotelListAsync = ref.watch(hotelProvider);

        return hotelListAsync.when(
          data: (hotelList) {
            return ListView.builder(
              itemCount: hotelList.length,
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                var count = hotelList.length > 10 ? 10 : hotelList.length;
                var animation = Tween(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: widget.animationController,
                    curve: Interval((1 / count) * index, 1.0,
                        curve: Curves.fastOutSlowIn),
                  ),
                );
                widget.animationController.forward();

                return HotelListView(
                  callback: () {
                    NavigationServices(context).gotoRoomBookingScreen(
                        hotelList[index].hotelName,
                        hotelList[index].hotelId,
                        hotelList[index].hotelAddress,
                        startDate.toString(),
                        endDate.toString());
                  },
                  hotelData: hotelList[index],
                  animation: animation,
                  animationController: widget.animationController,
                  isShowDate: true,
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        );
      },
    );
  }
}
