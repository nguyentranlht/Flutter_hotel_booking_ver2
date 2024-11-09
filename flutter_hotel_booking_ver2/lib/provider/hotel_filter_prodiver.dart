import 'package:flutter_hotel_booking_ver2/provider/hotel_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

class HotelFilter {
  final double minPrice;
  final double maxPrice;
  final double maxDistance;

  HotelFilter({
    this.minPrice = 100000.0,
    this.maxPrice = 2000000.0,
    this.maxDistance = 50.0,
  });
}

class HotelFilterNotifier extends StateNotifier<HotelFilter> {
  HotelFilterNotifier() : super(HotelFilter());

  void updatePriceRange(double minPrice, double maxPrice) {
    state = HotelFilter(
      minPrice: minPrice,
      maxPrice: maxPrice,
      maxDistance: state.maxDistance,
    );
  }

  void setMaxDistance(double distance) {
    state = HotelFilter(
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      maxDistance: distance,
    );
  }
}

final hotelFilterProvider =
    StateNotifierProvider<HotelFilterNotifier, HotelFilter>((ref) {
  return HotelFilterNotifier();
});

final hotelListProvider = FutureProvider<List<Hotel>>((ref) async {
  final hotelService = ref.watch(hotelServiceProvider);
  return hotelService.fetchHotels();
});

final filteredHotelProvider = Provider<AsyncValue<List<Hotel>>>((ref) {
  final filter = ref.watch(hotelFilterProvider);
  final hotelList = ref.watch(hotelListProvider);

  return hotelList.whenData((hotels) {
    return hotels
        .where((hotel) =>
            double.parse(hotel.perNight) >= filter.minPrice &&
            double.parse(hotel.perNight) <= filter.maxPrice &&
            hotel.distanceFromCenter <=
                filter.maxDistance) // Filter by distance
        .toList();
  });
});
