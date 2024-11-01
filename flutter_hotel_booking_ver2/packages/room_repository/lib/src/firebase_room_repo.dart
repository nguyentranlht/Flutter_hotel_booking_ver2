import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:room_repository/room_repository.dart';

class FirebaseRoomRepo implements RoomRepo {
  final roomsProvider =
      StreamProvider.family<List<Room>, String>((ref, hotelId) {
    final roomCollectionStream = FirebaseFirestore.instance
        .collection('Hotel')
        .doc(hotelId)
        .collection('Room')
        .snapshots();

    return roomCollectionStream.map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Room.fromEntity(RoomEntity.fromFirestore(doc)))
          .toList();
    });
  });
}
