import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String reviewId;
  final String userId;
  final String hotelId;
  final double rating;
  final String comments;
  final DateTime reviewDate;
  final String picture;
  final String fullname;
  final Map<String, int> categoryScores;

  Review({
    required this.reviewId,
    required this.userId,
    required this.hotelId,
    required this.rating,
    required this.comments,
    required this.reviewDate,
    required this.picture,
    required this.fullname,
    required this.categoryScores,
  });

  @override
  List<Object?> get props => [
        reviewId,
        userId,
        hotelId,
        rating,
        comments,
        reviewDate,
        picture,
        fullname,
        categoryScores,
      ];

  // Từ JSON sang đối tượng Review
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewId: json['reviewId'],
      userId: json['userId'],
      hotelId: json['hotelId'],
      rating: json['rating'],
      comments: json['comments'],
      reviewDate: (json['reviewDate'] as Timestamp).toDate(),
      picture: json['picture'],
      fullname: json['fullname'],
      categoryScores: Map<String, int>.from(json['categoryScores'] ?? {}),
    );
  }

  // Từ đối tượng Review sang JSON
  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'userId': userId,
      'hotelId': hotelId,
      'rating': rating,
      'comments': comments,
      'reviewDate': reviewDate,
      'picture': picture,
      'fullname': fullname,
      'categoryScores': categoryScores,
    };
  }
}
