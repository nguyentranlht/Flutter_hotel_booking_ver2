class LocationEntity {
  String x;
  String y;

  LocationEntity({
    required this.x,
    required this.y,
  });

  Map<String, Object?> toDocument() {
    return {
      'x': x,
      'y': y,
    };
  }

  static LocationEntity fromDocument(Map<String, dynamic> doc) {
    return LocationEntity(
      x: doc['x'],
      y: doc['y'],
    );
  }
}
