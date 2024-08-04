/// Represents a customer with an optional ID, first name, last name, address, and birthday.
class Customer {
  /// The unique identifier for the customer.
  final int? id;
  /// The first name of the customer.
  final String firstName;
  /// The first name of the customer.
  final String lastName;
  /// the address of the customer
  final String address;
  /// birthday of the customer
  final DateTime birthday;

  Customer({this.id, required this.firstName, required this.lastName, required this.address, required this.birthday});

  String get fullName => '$firstName $lastName';

  /// Converts the [Customer] instance to a map representation.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'birthday': birthday.toIso8601String(),
    };
  }

  /// Creates a new [Customer] instance from a map.
  ///
  /// The [map] must contain keys 'id', 'firstName', 'lastName', 'address', and 'birthday'.
  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      address: map['address'],
      birthday: DateTime.parse(map['birthday']),
    );
  }
}
