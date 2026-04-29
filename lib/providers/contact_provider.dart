import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/contact.dart';
import 'auth_provider.dart';

class ContactProvider extends ChangeNotifier {
  AuthProvider? _auth;
  List<Contact> _contacts = [];
  bool _isLoading = false;

  ContactProvider(this._auth);

  List<Contact> get contacts => _contacts;
  bool get isLoading => _isLoading;

  String get _baseUrl => 'https://www.pramari.de/coach/api/v1/contacts';

  void updateAuth(AuthProvider? auth) {
    _auth = auth;
    if (_auth?.accessToken != null && _contacts.isEmpty) {
      fetchContacts();
    }
  }

  Future<void> fetchContacts({bool isRetry = false}) async {
    final token = _auth?.accessToken;
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _contacts = data.map((item) => Contact.fromMap(item)).toList();
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await fetchContacts(isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addContact(Contact contact) async {
    return _addContactInternal(contact, isRetry: false);
  }

  Future<bool> _addContactInternal(Contact contact, {required bool isRetry}) async {
    final token = _auth?.accessToken;
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: contact.toJson(),
      );

      if (response.statusCode == 201) {
        final newContact = Contact.fromMap(jsonDecode(response.body));
        _contacts.add(newContact);
        notifyListeners();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _addContactInternal(contact, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error adding contact: $e');
    }
    return false;
  }
}
