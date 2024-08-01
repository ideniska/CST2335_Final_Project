class Flight {
  final int? id;
  final String departureCity;
  final String destinationCity;
  final String departureTime;
  final String arrivalTime;

  Flight({
    this.id,
    required this.departureCity,
    required this.destinationCity,
    required this.departureTime,
    required this.arrivalTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departureCity': departureCity,
      'destinationCity': destinationCity,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
    };
  }

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