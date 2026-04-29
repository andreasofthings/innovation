import 'package:flutter_test/flutter_test.dart';
import 'package:coach/models/contact.dart';

void main() {
  group('Contact Model Tests', () {
    test('Contact.fromMap should parse correctly', () {
      final map = {
        'id': '123',
        'first_name': 'John',
        'last_name': 'Doe',
        'email': 'john.doe@example.com',
      };
      final contact = Contact.fromMap(map);
      expect(contact.id, '123');
      expect(contact.firstName, 'John');
      expect(contact.lastName, 'Doe');
      expect(contact.email, 'john.doe@example.com');
      expect(contact.fullName, 'John Doe');
    });

    test('Contact.toJson should create correct map', () {
      final contact = Contact(
        id: '123',
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
      );
      final json = contact.toMap();
      expect(json['id'], '123');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['email'], 'john.doe@example.com');
    });
  });
}
