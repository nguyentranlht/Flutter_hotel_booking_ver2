import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MyUserEntity extends Equatable {
  final String userId;
  final String email;
  final String firstname;
  final String lastname;
  final String? picture;
  final String phonenumber;
  final DateTime birthday;
  final String role;

  const MyUserEntity({
    required this.userId,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.picture,
    required this.phonenumber,
    required this.birthday,
    required this.role,
  });

  Map<String, dynamic> toDocument() {
    return {
      'userId': userId,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'picture': picture,
      'phonenumber': phonenumber,
      'birthday':
          Timestamp.fromDate(birthday), // Chuyển DateTime thành Timestamp
      'role': role,
    };
  }

  static MyUserEntity fromDocument(Map<String, dynamic> doc) {
    return MyUserEntity(
        userId: doc['userId'] as String,
        email: doc['email'] as String,
        firstname: doc['firstname'] as String,
        lastname: doc['lastname'] as String,
        picture: doc['picture'] as String?,
        phonenumber: doc['phonenumber'] as String,
        birthday: (doc['birthday'] as Timestamp)
            .toDate(), // Chuyển Timestamp thành DateTime
        role: doc['role'] as String);
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        firstname,
        lastname,
        picture,
        phonenumber,
        birthday,
        role
      ];

  @override
  String toString() {
    return '''MyUserEntity: {
      userId: $userId,
      email: $email,
      firstname: $firstname,
      lastname: $lastname,
      picture: $picture,
      phonenumber: $phonenumber,
      birthday: $birthday,
      role: $role
    }''';
  }
}
