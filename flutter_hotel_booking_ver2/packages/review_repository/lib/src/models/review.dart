import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String reviewId;
  final String userId;
  final String hotelId;
  // String? imagePath;
  final int rating;
  final String comments;
  final DateTime reviewDate;
  final String picture;
  final String fullname;

  Review({
    required this.reviewId,
    required this.userId,
    // this.imagePath,
    required this.hotelId,
    required this.rating,
    required this.comments,
    required this.reviewDate,
    required this.picture,
    required this.fullname,
  });

  @override
  List<Object?> get props => [
        reviewId,
        userId,
        // imagePath,
        hotelId,
        rating,
        comments,
        reviewDate,
        picture,
        fullname
      ];
}
