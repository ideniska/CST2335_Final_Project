class Reservation {
  final int? id;
  final int customerId;
  final int flightId;
  final DateTime date;

  Reservation({this.id, required this.customerId, required this.flightId, required this.date});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'flightId': flightId,
      'date': date.toIso8601String(),
    };
  }

  factory Reservation.fromMap(Map<String, dynamic> map) {
    return Reservation(
      id: map['id'],
      customerId: map['customerId'],
      flightId: map['flightId'],
      date: DateTime.parse(map['date']),
    );
  }
}
