import 'package:flutter/material.dart';
import 'package:flutter_hotel_booking_ver2/modules/myTrips/hotel_favorites_list_view.dart';
import 'package:flutter_hotel_booking_ver2/provider/favorite_service.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_hotel_booking_ver2/routes/route_names.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoritesListView extends StatefulWidget {
  final AnimationController animationController;

  const FavoritesListView({Key? key, required this.animationController})
      : super(key: key);

  @override
  State<FavoritesListView> createState() => _FavoritesListViewState();
}

class _FavoritesListViewState extends State<FavoritesListView> {
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
        // Get favorite hotel IDs
        final favoriteHotelIdsAsync = ref.watch(favoriteHotelIdsProvider);
        final hotelListAsync = ref.watch(hotelProvider);

        return favoriteHotelIdsAsync.when(
          data: (favoriteHotelIds) {
            return hotelListAsync.when(
              data: (hotelList) {
                // Filter hotelList to include only favorite hotels
                final favoriteHotels = hotelList
                    .where((hotel) => favoriteHotelIds.contains(hotel.hotelId))
                    .toList();

                return ListView.builder(
                  itemCount: favoriteHotels.length,
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    var count =
                        favoriteHotels.length > 10 ? 10 : favoriteHotels.length;
                    var animation = Tween(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: widget.animationController,
                        curve: Interval((1 / count) * index, 1.0,
                            curve: Curves.fastOutSlowIn),
                      ),
                    );
                    widget.animationController.forward();

                    return HotelFavoriteListViewPage(
                      callback: () {
                        NavigationServices(context).gotoRoomBookingScreen(
                          favoriteHotels[index].hotelName,
                          favoriteHotels[index].hotelId,
                          favoriteHotels[index].hotelAddress,
                          startDate.toString(),
                          endDate.toString(),
                        );
                      },
                      hotelData: favoriteHotels[index],
                      animation: animation,
                      animationController: widget.animationController,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error loading hotels: $error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading favorites: $error')),
        );
      },
    );
  }
}
