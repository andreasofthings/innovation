import 'dart:convert';

class Contact {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? photoUrl;
  final String? googleContactId;
  final String source;

  Contact({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    this.googleContactId,
    this.source = 'manual',
  });

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id']?.toString() ?? '',
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photo_url'],
      googleContactId: map['google_contact_id'],
      source: map['source'] ?? 'manual',
    );
  }

  factory Contact.fromJson(String source) => Contact.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (googleContactId != null) 'google_contact_id': googleContactId,
      'source': source,
    };
  }

  String toJson() => json.encode(toMap());

  String get fullName => '$firstName $lastName';
}
