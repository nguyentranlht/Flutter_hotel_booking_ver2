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

  // Thêm khách sạn mới
  Future<void> addHotel(Hotel hotel) async {
    try {
      final docRef = _firestore.collection('hotels').doc();
      
      await docRef.set({
        'hotelId': docRef.id,
        'hotelName': hotel.hotelName,
        'imagePath': hotel.imagePath,
        'starRating': hotel.starRating,
        'location': GeoPoint(hotel.location.latitude, hotel.location.longitude),
        'dist': hotel.dist,
        'hotelAddress': hotel.hotelAddress,
        'description': hotel.description,
        'perNight': hotel.perNight,
        'distanceFromCenter': hotel.distanceFromCenter,
        'userId': hotel.userId,
        'isSelected': hotel.isSelected,
      });
    } catch (e) {
      throw Exception('Error adding hotel: $e');
    }
  }

  // Sửa thông tin khách sạn
  Future<void> updateHotel(Hotel hotel) async {
    try {
      await _firestore
          .collection('hotels')
          .doc(hotel.hotelId)
          .update(hotel.toMap());
    } catch (e) {
      throw Exception("Failed to update hotel: $e");
    }
  }

  // Xóa khách sạn
  Future<void> deleteHotel(String hotelId) async {
    try {
      await _firestore.collection('hotels').doc(hotelId).delete();
    } catch (e) {
      throw Exception("Failed to delete hotel: $e");
    }
  }
}
