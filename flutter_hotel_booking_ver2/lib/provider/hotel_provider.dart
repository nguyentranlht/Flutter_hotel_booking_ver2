import 'package:flutter_hotel_booking_ver2/provider/hotel_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

final hotelServiceProvider = Provider((ref) => HotelService());

final hotelProvider = FutureProvider<List<Hotel>>((ref) async {
  final hotelService = ref.watch(hotelServiceProvider);
  return hotelService.fetchHotels();
});
