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
    return 'https://id.pramari.de/application/o/userinfo/';
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
        Uri.parse(_baseUrl),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        _profile = UserProfile.fromJson(response.body);
        _hasError = false;
      } else {
        debugPrint('Failed to fetch profile: ${response.statusCode}');
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
    // Note: Standard OIDC userinfo endpoint is usually read-only.
    // If Authentik supports PATCHing the user via API, that would be a different endpoint.
    // For now, we update local state if successful, but standard UserInfo doesn't support PATCH.
    _profile = profile;
    notifyListeners();
    return true;
  }
}
