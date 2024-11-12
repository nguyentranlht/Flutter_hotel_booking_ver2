import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/hotel_list_view_data.dart';
import 'package:flutter_hotel_booking_ver2/provider/booking_provider.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpcomingListView extends ConsumerWidget {
  final AnimationController animationController;

  const UpcomingListView({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingBookings =
        ref.watch(upcomingBookingsProvider); // Directly List<Booking>

    final hotelListAsyncValue =
        ref.watch(hotelProvider); // HotelProvider as AsyncValue

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 1));

    return hotelListAsyncValue.when(
      data: (hotelList) {
        // Get the list of hotelIds from upcoming bookings
        final upcomingHotelIds =
            upcomingBookings.map((booking) => booking.hotelId).toSet();

        // Filter hotels to include only those in the upcomingHotelIds
        final upcomingHotels = hotelList
            .where((hotel) => upcomingHotelIds.contains(hotel.hotelId))
            .toList();

        return ListView.builder(
          itemCount: upcomingHotels.length,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var count = upcomingHotels.length > 10 ? 10 : upcomingHotels.length;
            var animation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            animationController.forward();

            // Get individual upcoming hotel information
            final hotelData = upcomingHotels[index];

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
