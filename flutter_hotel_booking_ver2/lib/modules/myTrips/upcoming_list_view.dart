import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/hotel_list_view_data.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/upcoming_details_view.dart';
import 'package:flutter_hotel_booking_ver2/provider/booking_provider.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

class UpcomingListView extends ConsumerWidget {
  final AnimationController animationController;

  const UpcomingListView({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingBookings =
        ref.watch(upcomingBookingsProvider); // List<Booking>
    final hotelListAsyncValue =
        ref.watch(hotelProvider); // AsyncValue<List<Hotel>>

    return hotelListAsyncValue.when(
      data: (hotelList) {
        return ListView.builder(
          itemCount: upcomingBookings.length,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemBuilder: (context, index) {
            var count =
                upcomingBookings.length > 10 ? 10 : upcomingBookings.length;
            var animation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            animationController.forward();

            // Get individual upcoming booking and hotel data
            final booking = upcomingBookings[index];
            final hotel = hotelList.firstWhere(
              (hotel) => hotel.hotelId == booking.hotelId,
              orElse: () => Hotel.empty(),
            );

            return HotelListViewData(
              callback: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailBookingsScreen(
                      hotelName: hotel.hotelName.toString(),
                      roomType: booking.numberOfGuests.toString(),
                      pricePerNight: booking.totalPrice.toString(),
                      checkInDate: booking.checkInDate,
                      checkOutDate: booking.checkOutDate,
                      hotelAddress: hotel.hotelAddress.toString(),
                      bookingId: booking.bookingId.toString(),
                      paymentIntentId: booking.paymentIntentId.toString(),
                    ),
                  ),
                );
              },
              hotelData: hotel,
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
