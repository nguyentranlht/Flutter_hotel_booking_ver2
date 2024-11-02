import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hotel_booking_ver2/provider/hotel_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

final hotelServiceProvider = Provider((ref) => HotelService());

final hotelProvider = FutureProvider<List<Hotel>>((ref) async {
  final hotelService = ref.watch(hotelServiceProvider);
  return hotelService.fetchHotels();
});

final hotelDetailProvider =
    FutureProvider.family<Hotel, String>((ref, hotelId) async {
  final doc =
      await FirebaseFirestore.instance.collection('hotels').doc(hotelId).get();
  if (doc.exists) {
    return Hotel.fromFirestore(doc);
  } else {
    throw Exception("Hotel not found");
  }
});
