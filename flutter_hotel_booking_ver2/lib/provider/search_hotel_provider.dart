import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_hotel_booking_ver2/provider/search_hotel_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotel_repository/hotel_repository.dart';

final searchCriteriaProvider = StateProvider<SearchCriteria>((ref) {
  return SearchCriteria(
    startDate: DateTime.now(),
    endDate: DateTime.now().add(const Duration(days: 1)),
    numberOfGuests: 2,
  );
});

final hotelSearchProvider = FutureProvider.autoDispose
    .family<List<Hotel>, SearchCriteria>((ref, criteria) async {
  final query = FirebaseFirestore.instance
      .collection('hotels')
      .where('rooms.maxGuests', isGreaterThanOrEqualTo: criteria.numberOfGuests)
      .where('rooms.availableDates',
          arrayContainsAny: [criteria.startDate, criteria.endDate]);
  final snapshot = await query.get();
  return snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
});
