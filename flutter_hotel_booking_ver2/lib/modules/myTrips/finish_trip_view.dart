import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/hotel_list_view_data.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishTripView extends ConsumerWidget {
  final AnimationController animationController;

  const FinishTripView({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotelListAsyncValue =
        ref.watch(hotelProvider); // Ensure `hotelProvider` fetches hotel list

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));

    return hotelListAsyncValue.when(
      data: (hotelList) {
        return ListView.builder(
          itemCount: hotelList.length,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var count = hotelList.length > 10 ? 10 : hotelList.length;
            var animation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            animationController.forward();

            // Get individual hotel information
            final hotelData = hotelList[index];

            return HotelListViewData(
              callback: () {
                NavigationServices(context).gotoRoomBookingScreen(
                  hotelData.hotelName,
                  hotelData.hotelId,
                  hotelData.hotelAddress,
                  startDate.toString(),
                  endDate.toString(),
                );
              },
              hotelData: hotelData,
              animation: animation,
              animationController: animationController,
              isShowDate: (index % 2) != 0,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error loading hotels')),
    );
  }
}
