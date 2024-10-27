import 'package:equatable/equatable.dart';
import 'package:hotel_repository/src/models/location.dart';
import '../entities/entities.dart';

class Hotel extends Equatable {
  final String hotelId;
  final String hotelName;
  String? imagePath;
  final double starRating;
  final Location location;
  final String hotelAddress;
  final String descrition;

  Hotel({
    required this.hotelId,
    required this.hotelName,
    this.imagePath,
    required this.starRating,
    required this.location,
    required this.hotelAddress,
    required this.descrition,
  });

  static final empty = Hotel(
    hotelId: '',
    hotelName: '',
    imagePath: '',
    starRating: 0.0,
    location: Location.empty,
    hotelAddress: '',
    descrition: '',
  );

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == Hotel.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != Hotel.empty;

  HotelEntity toEntity() {
    return HotelEntity(
      hotelId: hotelId,
      hotelName: hotelName,
      imagePath: imagePath,
      starRating: starRating,
      location: location,
      hotelAddress: hotelAddress,
      descrition: descrition,
    );
  }

  static Hotel fromEntity(HotelEntity entity) {
    return Hotel(
      hotelId: entity.hotelId,
      hotelName: entity.hotelName,
      imagePath: entity.imagePath,
      starRating: entity.starRating,
      location: entity.location,
      hotelAddress: entity.hotelAddress,
      descrition: entity.descrition,
    );
  }

  @override
  List<Object?> get props => [
        hotelId,
        hotelName,
        imagePath,
        starRating,
        location,
        hotelAddress,
        descrition,
      ];

  @override
  String toString() {
    return '''Hotel: {
      hotelId: $hotelId,
      hotelName: $hotelName,
      imagePath: $imagePath,
      starRating: $starRating,
      location: $location,
      hotelAddress: $hotelAddress,
      descrition: $descrition,
    }''';
  }
}
