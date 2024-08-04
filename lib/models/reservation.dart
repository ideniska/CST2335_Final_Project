/// Represents a reservation for a flight.
///
/// Contains details about the reservation including customer ID, flight ID, 
/// reservation date, and the name of the reservation.
class Reservation {
  /// Unique identifier for the reservation.
  final int? id;

  /// Identifier of the customer making the reservation.
  final int customerId;

  /// Identifier of the flight for which the reservation is made.
  final int flightId;

  /// Date and time when the reservation is made.
  final DateTime date;

  /// Name associated with the reservation.
  final String name;

  /// Creates a new [Reservation] instance.
  ///
  /// The [id] is optional and is usually provided by the database.
  /// The [customerId], [flightId], [date], and [name] are required.
  Reservation({
    this.id,
    required this.customerId,
    required this.flightId,
    required this.date,
    required this.name,
  });

  /// Converts the [Reservation] instance to a map.
  ///
  /// The map can be used to store the reservation in a database or transfer it 
  /// between different parts of the application.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'flightId': flightId,
      'date': date.toIso8601String(),
      'name': name,
    };
  }

  /// Creates a [Reservation] instance from a map.
  ///
  /// The map is typically retrieved from a database or received from an API.
  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      customerId: map['customerId'],
      flightId: map['flightId'],
      date: DateTime.parse(map['date']),
      name: map['name'],
    );
  }
}