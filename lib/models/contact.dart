import 'dart:convert';

class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String email;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  factory Contact.fromJson(String source) => Contact.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
  }

  String toJson() => json.encode(toMap());

  String get fullName => '$firstName $lastName';
}
