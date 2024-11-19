import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

class MyUser extends Equatable {
  final String userId;
  late final String email;
  late final String firstname;
  late final String lastname;
  String? picture;
  final String phonenumber;
  final DateTime birthday; // Chuyển đổi sang DateTime
  final String role;
  final String status;
  MyUser({
    required this.userId,
    required this.email,
    required this.firstname,
    required this.lastname,
    this.picture,
    required this.phonenumber,
    required this.birthday, // Chuyển đổi sang DateTime
    required this.role,
    required this.status,
  });

  /// Empty user which represents an unauthenticated user.
  static final empty = MyUser(
    userId: '', // Hoặc để trống nếu không cần tại thời điểm này
    email: '',
    firstname: '',
    lastname: '',
    picture: null, // Nếu không có ảnh
    phonenumber: '', // Nếu chưa có số điện thoại
    birthday: DateTime.now(), // Nếu không có ngày sinh cụ thể
    role: 'user',
    status: 'active',
  );

  /// Modify MyUser parameters
  MyUser copyWith({
    String? userId,
    String? email,
    String? firstname,
    String? lastname,
    String? picture,
    String? phonenumber,
    DateTime? birthday, // Chuyển đổi sang DateTime
    String? role,
    String? status,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      picture: picture ?? this.picture,
      phonenumber: phonenumber ?? this.phonenumber,
      birthday: birthday ?? this.birthday, // Chuyển đổi sang DateTime
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == MyUser.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != MyUser.empty;

  /// Chuyển MyUser thành MyUserEntity để lưu trữ
  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      email: email,
      firstname: firstname,
      lastname: lastname,
      picture: picture,
      phonenumber: phonenumber,
      birthday: birthday, // Sử dụng DateTime
      role: role,
      status: status,
    );
  }

  /// Tạo MyUser từ MyUserEntity khi đọc từ Firestore
  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      email: entity.email,
      firstname: entity.firstname,
      lastname: entity.lastname,
      picture: entity.picture,
      phonenumber: entity.phonenumber,
      birthday: entity.birthday, // Sử dụng DateTime từ entity
      role: entity.role,
      status: entity.status,
    );
  }

  @override
<<<<<<< Updated upstream
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
=======
  List<Object?> get props =>
      [userId, email, fullname, picture, phonenumber, birthday, role, status];
>>>>>>> Stashed changes
}
