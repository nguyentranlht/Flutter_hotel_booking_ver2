import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      await favoriteRef.delete();
    } else {
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
