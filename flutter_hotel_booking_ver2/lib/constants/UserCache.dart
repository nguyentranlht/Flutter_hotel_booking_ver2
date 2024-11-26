import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:user_repository/user_repository.dart';

class UserCache {
  // Lưu dữ liệu người dùng dưới dạng JSON
  static Future<void> saveUserData(MyUser user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'userId': user.userId,
      'email': user.email,
      'fullname': user.fullname,
      'picture': user.picture,
      'phonenumber': user.phonenumber,
      'birthday':
          user.birthday.toIso8601String(), // Lưu DateTime dưới dạng chuỗi
      'role': user.role,
      'status': user.status,
    };
    await prefs.setString('userData', jsonEncode(userData));
  }

  // Lấy dữ liệu người dùng từ bộ nhớ đệm
  static Future<MyUser?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString('userData');

    if (userDataString == null) {
      return null;
    }

    final userData = jsonDecode(userDataString) as Map<String, dynamic>;

    return MyUser(
      userId: userData['userId'],
      email: userData['email'],
      fullname: userData['fullname'],
      picture: userData['picture'],
      phonenumber: userData['phonenumber'],
      birthday: DateTime.parse(
          userData['birthday']), // Chuyển đổi lại từ chuỗi sang DateTime
      role: userData['role'],
      status: userData['status'],
    );
  }

  // Xóa dữ liệu người dùng khỏi bộ nhớ đệm
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userData');
  }
}
