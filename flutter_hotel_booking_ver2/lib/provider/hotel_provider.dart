import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';
import 'package:review_repository/review_repository.dart';

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

  Future<void> deleteHotel(String hotelId) async {
    try {
      await hotelService.deleteHotel(hotelId);
      state = state.where((hotel) => hotel.hotelId != hotelId).toList();
    } catch (e) {
      throw Exception('Failed to delete hotel: $e');
    }
  }

  //Function find hotel and price, address
  Future<void> searchHotels({
    required String searchQuery, // find keyword(name hotel, address)
    required double minPrice, // min Price
    required double maxPrice, // max Price
  }) async {
    final hotels = await hotelService.fetchHotels(); // Get all hotel
    state = hotels.where((hotel) {
      final price = double.tryParse(hotel.perNight) ?? 0.0;
      final matchesSearchQuery = hotel.hotelName
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          hotel.hotelAddress.toLowerCase().contains(searchQuery.toLowerCase());

      final withinPriceRange = price >= minPrice && price <= maxPrice;

      return matchesSearchQuery && withinPriceRange;
    }).toList();
  }
}

class AddHotelNotifier extends StateNotifier<AsyncValue<void>> {
  final HotelService _hotelService;

  AddHotelNotifier(this._hotelService) : super(const AsyncValue.data(null));

  Future<void> addHotel(Hotel hotel) async {
    state = const AsyncValue.loading();
    try {
      await _hotelService.addHotel(hotel);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final addHotelProvider =
    StateNotifierProvider<AddHotelNotifier, AsyncValue<void>>((ref) {
  final hotelService = ref.watch(hotelServiceProvider);
  return AddHotelNotifier(hotelService);
});

final reviewsProvider =
    StreamProvider.family<List<Review>, String>((ref, hotelId) {
  return FirebaseFirestore.instance
      .collection('reviews')
      .where('hotelId', isEqualTo: hotelId)
      .orderBy('reviewDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Review(
                reviewId: doc['reviewId'],
                userId: doc['userId'],
                hotelId: doc['hotelId'],
                rating: doc['rating'],
                comments: doc['comments'],
                reviewDate: (doc['reviewDate'] as Timestamp).toDate(),
                picture: doc['picture'],
                fullname: doc['fullname'],
              ))
          .toList());
});
