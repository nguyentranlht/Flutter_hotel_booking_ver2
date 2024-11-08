import 'package:flutter_hotel_booking_ver2/provider/hotel_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

final hotelServiceProvider = Provider((ref) => HotelService());

final hotelProvider = FutureProvider<List<Hotel>>((ref) async {
  final hotelService = ref.watch(hotelServiceProvider);
  return hotelService.fetchHotels();
});

final hotelListProvider =
    StateNotifierProvider<HotelListNotifier, List<Hotel>>((ref) {
  final hotelService = ref.read(hotelServiceProvider);
  return HotelListNotifier(hotelService);
});

class HotelListNotifier extends StateNotifier<List<Hotel>> {
  final HotelService hotelService;

  HotelListNotifier(this.hotelService) : super([]);

  Future<void> fetchHotels(
      double minPrice, double maxPrice, double maxDistance) async {
    final hotels = await hotelService
        .fetchHotels(); // Assume fetchHotels fetches all hotels
    state = hotels.where((hotel) {
      final withinPriceRange = int.parse(hotel.perNight) >= minPrice &&
          int.parse(hotel.perNight) <= maxPrice;

      return withinPriceRange;
    }).toList();
  }
}
