import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_repository/user_repository.dart';
import 'user_service.dart';

// Provider for the UserService instance
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Provider for fetching MyUser data
final userProvider =
    FutureProvider.family<MyUser?, String>((ref, userId) async {
  final userService = ref.watch(userServiceProvider);
  return userService.fetchUser(userId);
});
