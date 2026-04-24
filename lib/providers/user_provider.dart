import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';

class UserProvider extends ChangeNotifier {
  String? _accessToken;
  UserProfile? _profile;
  bool _isLoading = false;
  bool _hasError = false;

  UserProvider(this._accessToken) {
    if (_accessToken != null) {
      fetchProfile();
    }
  }

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  String get _baseUrl {
    return 'https://id.pramari.de/api/v3/core/users';
  }

  Future<void> updateToken(String? newToken) async {
    if (_accessToken == newToken) return;
    _accessToken = newToken;
    if (_accessToken != null) {
      await fetchProfile();
    } else {
      _profile = null;
      _hasError = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    if (_accessToken == null) return;

    _isLoading = true;
    _hasError = false;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/me/'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _profile = UserProfile.fromJson(response.body);
        _hasError = false;
      } else {
        debugPrint('Failed to fetch profile: ${response.statusCode} ${response.body}');
        _hasError = true;
        _profile ??= _getDefaultProfile();
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      _hasError = true;
      _profile ??= _getDefaultProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  UserProfile _getDefaultProfile() {
    return UserProfile(
      language: 'en',
      confidence: 0.5,
      defaultWorkshopLength: 60,
      defaultWorkshopSetting: 'on-site',
      defaultGroupSize: 10,
      isGoogleConnected: false,
      color: '#25AFF4',
      icon: 'person',
      country: '',
      name: 'User',
      email: '',
    );
  }

  Future<bool> updateProfile(UserProfile profile) async {
    if (_accessToken == null || profile.pk == null) {
      debugPrint('Update failed: Missing access token or user PK');
      _profile = profile; // Update local anyway
      notifyListeners();
      return false;
    }

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/${profile.pk}/'),
        headers: {
          'Authorization': 'Bearer $_accessToken',
          'Content-Type': 'application/json',
        },
        body: profile.toJson(),
      );

      if (response.statusCode == 200) {
        _profile = UserProfile.fromJson(response.body);
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to update profile: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }
}
