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
                // Lấy userId của người dùng hiện tại từ Firebase Auth
                final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                if (currentUserId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Người dùng chưa đăng nhập."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final userAsync = ref.watch(userProvider(currentUserId));

                // Xử lý trạng thái của userAsync
                if (userAsync is AsyncLoading) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đang tải thông tin người dùng..."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                if (userAsync is AsyncError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Không thể tải thông tin người dùng."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // Lấy fullname nếu dữ liệu đã tải thành công
                final fullname = userAsync.whenOrNull(
                  data: (user) => user?.fullname ?? 'Người dùng',
                );

                if (fullname == null || fullname.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Tên người dùng không hợp lệ."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                NavigationServices(context).gotoReviewsScreen(
                  hotelData,
                  hotelData.hotelId,
                  currentUserId, // Sử dụng currentUserId
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
      error: (error, stackTrace) => Center(child: Text('Error loading hotels')),
    );
  }
}
