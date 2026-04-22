import 'package:flutter/foundation.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import '../models/user_profile.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserProvider extends ChangeNotifier {
  final oauth2.Client? _client;
  UserProfile? _profile;
  bool _isLoading = false;

  UserProvider(this._client) {
    if (_client != null) {
      fetchProfile();
    }
  }

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  String get _baseUrl {
    final tokenEndpoint = dotenv.env['OAUTH_TOKEN_ENDPOINT'] ?? 'https://pramari.de/oauth2/token';
    final uri = Uri.parse(tokenEndpoint);
    return '${uri.scheme}://${uri.host}/api/profile';
  }

  Future<void> fetchProfile() async {
    if (_client == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client!.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        _profile = UserProfile.fromJson(response.body);
      } else {
        debugPrint('Failed to fetch profile: ${response.statusCode}');
        // Fallback or initial profile if not found
        _profile = UserProfile(
          language: 'en',
          confidence: 0.5,
          defaultWorkshopLength: 60,
          defaultWorkshopSetting: 'on-site',
          defaultGroupSize: 10,
          isGoogleConnected: false,
          color: '#25AFF4',
          icon: 'person',
          country: '',
        );
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(UserProfile profile) async {
    if (_client == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _client!.patch(
        Uri.parse(_baseUrl),
        body: profile.toJson(),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _profile = profile;
        return true;
      } else {
        debugPrint('Failed to update profile: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
