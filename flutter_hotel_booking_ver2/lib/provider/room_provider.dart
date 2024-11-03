// providers/room_provider.dart
import 'package:flutter_hotel_booking_ver2/provider/room_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_repository/room_repository.dart';

// providers/room_provider.dart
final roomServiceProvider = Provider((ref) => RoomService());

final roomsProvider = StreamProvider.family<List<Room>, String>((ref, hotelId) {
  final roomService = ref.watch(roomServiceProvider);
  return roomService.streamRoomsByHotelId(hotelId);
});
