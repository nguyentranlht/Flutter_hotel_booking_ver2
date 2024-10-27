class ReviewEntity {
  final String reviewId;
  final String userId;
  final String hotelId;
  // String? imagePath;
  final int rating;
  final String comments;
  final DateTime reviewDate;

  ReviewEntity({
    required this.reviewId,
    required this.userId,
    // this.imagePath,
    required this.hotelId,
    required this.rating,
    required this.comments,
    required this.reviewDate,
  });

  Map<String, Object?> toDocument() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      // 'imagePath': imagePath,
      'hotelId': hotelId,
      'rating': rating,
      'comments': comments,
      'reviewData': reviewDate,
    };
  }

  static ReviewEntity fromDocument(Map<String, dynamic> doc) {
    return ReviewEntity(
      reviewId: doc['reviewId'],
      userId: doc['userId'],
      //imagePath: doc['imagePath'],
      hotelId: doc['hotelId'],
      rating: doc['rating'],
      comments: doc['comments'],
      reviewDate: doc['reviewDate'],
    );
  }
}
