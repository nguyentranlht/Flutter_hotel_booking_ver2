import '../entities/location_entity.dart';

class Location {
  String x;
  String y;

  Location({
    required this.x,
    required this.y,
  });
  static final empty = Location(
    x: '',
    y: '',
  );
  LocationEntity toEntity() {
    return LocationEntity(
      x: x,
      y: y,
    );
  }

  static Location fromEntity(LocationEntity entity) {
    return Location(
      x: entity.x,
      y: entity.y,
    );
  }

  // Thêm phương thức fromMap để chuyển đổi từ Map<String, dynamic>
  static Location fromMap(Map<String, dynamic> data) {
    return Location(
      x: data['x'] ?? '',
      y: data['y'] ?? '',
    );
  }
}
