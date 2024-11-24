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
final selectedRoomProvider = StateProvider<Room?>((ref) => null);
final addRoomProvider =
    StateNotifierProvider<AddRoomNotifier, AsyncValue<void>>((ref) {
  final roomService = ref.read(roomServiceProvider);
  return AddRoomNotifier(roomService);
});

class AddRoomNotifier extends StateNotifier<AsyncValue<void>> {
  final RoomService _roomService;

  AddRoomNotifier(this._roomService) : super(const AsyncValue.data(null));

  Future<void> addRoom(Room room) async {
    state = const AsyncValue.loading();
    try {
      await _roomService.addRoom(room);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
// final roomsAvailableProvider =
//     StreamProvider.family<List<Room>, SearchCriteria>((ref, criteria) {
//   final roomService = ref.watch(roomServiceProvider);

//   // Chuyển đổi startDate và endDate từ DateTime sang String theo định dạng yyyy-MM-dd
//   final startDateString = DateFormat('yyyy-MM-dd').format(criteria.startDate);
//   final endDateString = DateFormat('yyyy-MM-dd').format(criteria.endDate);

//   // Truyền startDateString và endDateString vào hàm streamAvailableRooms
//   return roomService.streamAvailableRooms(
//       startDateString, endDateString, criteria.numberOfGuests);
// });
