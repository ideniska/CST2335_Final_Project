class Customer {
  final int? id;
  final String firstName;
  final String lastName;
  final String address;
  final DateTime birthday;

  Customer({this.id, required this.firstName, required this.lastName, required this.address, required this.birthday});

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'address': address,
      'birthday': birthday.toIso8601String(),
    };
  }

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