import 'package:flutter_hotel_booking_ver2/provider/favorite_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for FavoriteService
final favoriteServiceProvider = Provider((ref) => FavoriteService());

/// Favorite hotel IDs provider that uses FavoriteService
final favoriteHotelIdsProvider = StreamProvider<List<String>>((ref) {
  return ref.read(favoriteServiceProvider).getFavoriteHotelIds();
});
