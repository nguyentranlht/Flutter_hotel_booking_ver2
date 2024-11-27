import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/hotel_list_view_data.dart';
import 'package:flutter_hotel_booking_ver2/provider/booking_provider.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_hotel_booking_ver2/provider/user_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinishTripView extends ConsumerWidget {
  final AnimationController animationController;

  const FinishTripView({Key? key, required this.animationController})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finishedBookings =
        ref.watch(finishedBookingsProvider); // Trực tiếp là List<Booking>

    final hotelListAsyncValue =
        ref.watch(hotelProvider); // HotelProvider là một AsyncValue

    return hotelListAsyncValue.when(
      data: (hotelList) {
        // Lấy danh sách hotelIds từ các bookings đã hoàn thành
        final finishedHotelIds =
            finishedBookings.map((booking) => booking.hotelId).toSet();

        // Lọc các hotel có trong danh sách finishedHotelIds
        final finishedHotels = hotelList
            .where((hotel) => finishedHotelIds.contains(hotel.hotelId))
            .toList();

        return ListView.builder(
          itemCount: finishedHotels.length,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            var count = finishedHotels.length > 10 ? 10 : finishedHotels.length;
            var animation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval((1 / count) * index, 1.0,
                    curve: Curves.fastOutSlowIn),
              ),
            );
            animationController.forward();

            // Get individual finished hotel information
            final hotelData = finishedHotels[index];

            return HotelListViewData(
              callback: () {
                final userAsync = ref.read(userProvider(hotelData.userId));
                final fullname = userAsync.maybeWhen(
                  data: (user) => user?.fullname ?? 'Người dùng',
                  orElse: () => 'Người dùng',
                );

                NavigationServices(context).gotoReviewsScreen(
                  hotelData,
                  hotelData.hotelId,
                  hotelData.userId,
                  fullname, // Truyền fullname vào
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
