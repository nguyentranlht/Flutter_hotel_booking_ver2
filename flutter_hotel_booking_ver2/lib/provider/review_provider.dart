import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider quản lý rating
final ratingProvider =
    StateProvider<double>((ref) => 1); // Giá trị mặc định là 1

// Provider quản lý nhận xét
final commentsProvider = StateProvider<String>((ref) => "");

// Provider quản lý trạng thái gửi
final isSubmittingProvider = StateProvider<bool>((ref) => false);

final roomRatingProvider = StateProvider<int>((ref) => 1);
final serviceRatingProvider = StateProvider<int>((ref) => 1);
final locationRatingProvider = StateProvider<int>((ref) => 1);
final priceRatingProvider = StateProvider<int>((ref) => 1);
