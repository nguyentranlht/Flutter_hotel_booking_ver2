import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_repository/user_repository.dart';
import 'user_service.dart';

// Provider for the UserService instance
final userServiceProvider = Provider<UserService>((ref) {
  return UserService();
});

// Provider for fetching MyUser data
final userProvider =
    StreamProvider.family<MyUser?, String>((ref, userId) async* {
  final userService = ref.watch(userServiceProvider);
  yield* userService.fetchUser(userId);
});
// Provider for uploading a profile picture and updating user's picture URL
final uploadPictureProvider =
    FutureProvider.family<String?, MyUser>((ref, params) async {
  final userService = ref.watch(userServiceProvider);
  return userService.uploadPicture(params.picture, params.userId);
});

final uploadUserProvider =
    FutureProvider.family<void, MyUser>((ref, params) async {
  final userService = ref.watch(userServiceProvider);
  userService.updateUser(params);
});
