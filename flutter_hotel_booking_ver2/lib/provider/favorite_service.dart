import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FavoriteService class that fetches userId internally
class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retrieves the current user's ID from FirebaseAuth
  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  Future<void> toggleFavoriteHotel(String hotelId) async {
    final userId = _userId;
    if (userId == null) return; // Handle the case where userId is null

    final favoriteRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(hotelId);

    final docSnapshot = await favoriteRef.get();
    if (docSnapshot.exists) {
      // If hotel is already in favorites, remove it
      await favoriteRef.delete();
    } else {
      // If hotel is not in favorites, add it
      await favoriteRef
          .set({'hotelId': hotelId, 'timestamp': FieldValue.serverTimestamp()});
    }
  }

  Stream<List<String>> getFavoriteHotelIds() {
    final userId = _userId;
    if (userId == null) {
      // Return an empty stream if no user is logged in
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }
}

/// Provider for FavoriteService
final favoriteServiceProvider = Provider((ref) => FavoriteService());

/// Favorite hotel IDs provider that uses FavoriteService
final favoriteHotelIdsProvider = StreamProvider<List<String>>((ref) {
  return ref.read(favoriteServiceProvider).getFavoriteHotelIds();
});
