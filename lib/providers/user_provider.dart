import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  final String? _accessToken;
  UserProfile? _profile;
  bool _isLoading = false;

  UserProvider(this._accessToken) {
    if (_accessToken != null) {
      fetchProfile();
    }
  }

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  String get _baseUrl {
    // Fallback to a default if environment variable is not set
    const tokenEndpoint = String.fromEnvironment('OAUTH_TOKEN_ENDPOINT', defaultValue: 'https://id.pramari.de/application/o/innovation/');
    final uri = Uri.parse(tokenEndpoint);
    // Authentik usually has profile at /application/o/userinfo/ or similar,
    // but based on previous code it was /api/profile.
    // Let's assume the user knows their API structure.
    return '${uri.scheme}://${uri.host}/api/profile';
  }

  Future<void> fetchProfile() async {
    if (_accessToken == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        _profile = UserProfile.fromJson(response.body);
      } else {
        debugPrint('Failed to fetch profile: ${response.statusCode}');
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
    if (_accessToken == null) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.patch(
        Uri.parse(_baseUrl),
        body: profile.toJson(),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
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
