import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

class Review extends Equatable {
  final String reviewId;
  final String userId;
  final String hotelId;
  // String? imagePath;
  final int rating;
  final String comments;
  final DateTime reviewDate;

  Review({
    required this.reviewId,
    required this.userId,
    // this.imagePath,
    required this.hotelId,
    required this.rating,
    required this.comments,
    required this.reviewDate,
  });

  static final empty = Review(
    reviewId: '',
    userId: '',
    hotelId: '',
    rating: 0,
    comments: '',
    reviewDate: DateTime(1970, 1, 1),
  );

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == Review.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != Review.empty;

  ReviewEntity toEntity() {
    return ReviewEntity(
      reviewId: reviewId,
      userId: userId,
      hotelId: hotelId,
      rating: rating,
      comments: comments,
      reviewDate: reviewDate,
    );
  }

  static Review fromEntity(ReviewEntity entity) {
    return Review(
      reviewId: entity.reviewId,
      userId: entity.userId,
      hotelId: entity.hotelId,
      rating: entity.rating,
      comments: entity.comments,
      reviewDate: entity.reviewDate,
    );
  }

  @override
  List<Object?> get props => [
        reviewId,
        userId,
        // imagePath,
        hotelId,
        rating,
        comments,
        reviewDate,
      ];

  @override
  String toString() {
    return '''Review: {
      reviewId: $reviewId,
      userId: $userId,
      hotelId: $hotelId,
      rating: $rating,
      comments: $comments,
      reviewDate: $reviewDate,
    }''';
    //  imagePath: $imagePath,
  }
}
