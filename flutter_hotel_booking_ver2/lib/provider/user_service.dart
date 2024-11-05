import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_repository/user_repository.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MyUser?> fetchUser(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection('users').doc(userId).get();

      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null) {
          return MyUser(
            userId: userId,
            email: data['email'],
            firstname: data['firstname'],
            lastname: data['lastname'],
            picture: data['picture'],
            phonenumber: data['phonenumber'],
            birthday: (data['birthday'] as Timestamp).toDate(),
            role: data['role'],
          );
        }
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }
}
