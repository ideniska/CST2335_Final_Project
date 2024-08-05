/// A class representing a flight.
///
/// This class includes properties for the flight's ID, departure city, destination city,
/// departure time, and arrival time. It also includes methods for converting the flight
/// to and from a map, which is useful for database operations.
class Flight {
  final int? id;
  final String departureCity;
  final String destinationCity;
  final String departureTime;
  final String arrivalTime;

  /// Creates a new [Flight] instance.
  ///
  /// [id] The ID of the flight. This is optional.
  /// [departureCity] The city from which the flight departs. This is required.
  /// [destinationCity] The city to which the flight is destined. This is required.
  /// [departureTime] The departure time of the flight. This is required.
  /// [arrivalTime] The arrival time of the flight. This is required.
  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });

  /// Converts the flight to a map.
  ///
  /// This method is useful for converting the flight to a format
  /// that can be stored in a database.
  ///
  /// Returns a map representation of the flight.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
    };
  }

  /// Creates a new [Flight] instance from a map.
  ///
  /// This method is useful for converting a map from a database
  /// to a [Flight] instance.
  ///
  /// [map] The map representation of the flight.
  ///
  /// Returns a new [Flight] instance.
  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id'],
      departureCity: map['departureCity'],
      destinationCity: map['destinationCity'],
      departureTime: map['departureTime'],
      arrivalTime: map['arrivalTime'],
    );
  }
}
