import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hotel_repository/hotel_repository.dart';

class HotelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Hotel>> fetchHotels() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('hotels').get();
      return snapshot.docs.map((doc) => Hotel.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception("Failed to fetch hotels: $e");
    }
  }
}
