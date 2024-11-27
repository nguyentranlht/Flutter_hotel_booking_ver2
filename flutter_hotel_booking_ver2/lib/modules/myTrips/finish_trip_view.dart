import 'package:firebase_auth/firebase_auth.dart';
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
    // Lấy userId hiện tại từ Firebase Auth
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      return const Center(
        child: Text("Người dùng chưa đăng nhập.",
            style: TextStyle(color: Colors.red)),
      );
    }

    // Preload user data
    final userAsync = ref.watch(userProvider(currentUserId));
    if (userAsync is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (userAsync is AsyncError) {
      return const Center(
        child: Text("Không thể tải thông tin người dùng.",
            style: TextStyle(color: Colors.red)),
      );
    }

    final fullname = userAsync.whenOrNull(
      data: (user) => user?.fullname ?? 'Người dùng',
    );

    if (fullname == null || fullname.isEmpty) {
      return const Center(
        child: Text("Tên người dùng không hợp lệ.",
            style: TextStyle(color: Colors.red)),
      );
    }

    // Fetch bookings and hotels
    final finishedBookings = ref.watch(finishedBookingsProvider);
    final hotelListAsyncValue = ref.watch(hotelProvider);

    return hotelListAsyncValue.when(
      data: (hotelList) {
        final finishedHotelIds =
            finishedBookings.map((booking) => booking.hotelId).toSet();
        final finishedHotels = hotelList
            .where((hotel) => finishedHotelIds.contains(hotel.hotelId))
            .toList();

        if (finishedHotels.isEmpty) {
          return const Center(
            child: Text(
              "Không có chuyến đi nào đã hoàn thành.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
        }

        return ListView.builder(
          itemCount: finishedHotels.length,
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          itemBuilder: (context, index) {
            final hotelData = finishedHotels[index];

            final animation = Tween(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animationController,
                curve: Interval(
                  (1 / finishedHotels.length) * index,
                  1.0,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
            );

            animationController.forward();

            return HotelListViewData(
              callback: () {
                NavigationServices(context).gotoReviewsScreen(
                  hotelData,
                  hotelData.hotelId,
                  currentUserId,
                  fullname,
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
      error: (error, stackTrace) => Center(
        child: Text("Có lỗi xảy ra: $error",
            style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}
