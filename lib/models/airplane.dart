/// A class representing an airplane.
///
/// This class includes properties for the airplane's ID, type, number of passengers,
/// maximum speed, and range. It also includes methods for converting the airplane
/// to and from a map, which is useful for database operations.
class Airplane {
  final int? id;
  final String type;
  final int passengers;
  final double maxSpeed;
  final double range;

  /// Creates a new [Airplane] instance.
  ///
  /// [id] The ID of the airplane. This is optional.
  /// [type] The type of the airplane. This is required.
  /// [passengers] The number of passengers the airplane can carry. This is required.
  /// [maxSpeed] The maximum speed of the airplane. This is required.
  /// [range] The range of the airplane. This is required.
  Airplane({this.id, required this.type, required this.passengers, required this.maxSpeed, required this.range});

  /// Converts the airplane to a map.
  ///
  /// This method is useful for converting the airplane to a format
  /// that can be stored in a database.
  ///
  /// Returns a map representation of the airplane.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'passengers': passengers,
      'maxSpeed': maxSpeed,
      'range': range,
    };
  }

  /// Creates a new [Airplane] instance from a map.
  ///
  /// This method is useful for converting a map from a database
  /// to an [Airplane] instance.
  ///
  /// [map] The map representation of the airplane.
  ///
  /// Returns a new [Airplane] instance.
  factory Airplane.fromMap(Map<String, dynamic> map) {
    return Airplane(
      id: map['id'],
      type: map['type'],
      passengers: map['passengers'],
      maxSpeed: map['maxSpeed'],
      range: map['range'],
    );
  }
}