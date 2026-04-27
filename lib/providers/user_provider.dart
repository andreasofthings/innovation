import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import 'auth_provider.dart';

class UserProvider extends ChangeNotifier {
  AuthProvider? _auth;
  UserProfile? _profile;
  bool _isLoading = false;
  bool _hasError = false;

  UserProvider(this._auth) {
    if (_auth?.accessToken != null) {
      fetchProfile();
    }
  }

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  String get _baseUrl {
    return 'https://www.pramari.de/coach/api/v2/profile';
  }

  Future<void> updateAuth(AuthProvider? auth) async {
    final oldToken = _auth?.accessToken;
    _auth = auth;
    final newToken = _auth?.accessToken;

    if (newToken != null && oldToken != newToken) {
      await fetchProfile();
    } else if (newToken == null) {
      _profile = null;
      _hasError = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile({bool isRetry = false}) async {
    final token = _auth?.accessToken;
    if (token == null) return;

    _isLoading = true;
    _hasError = false;
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
        _profile = UserProfile.fromJson(response.body);
        _hasError = false;
      } else if (response.statusCode == 401 && !isRetry) {
        debugPrint('Fetch profile unauthorized, attempting token refresh');
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await fetchProfile(isRetry: true);
        } else {
          _hasError = true;
          _profile ??= _getDefaultProfile();
        }
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
      level: 1,
    );
  }

  /// Updates the profile. If [optimistic] is true, it updates the local state immediately.
  Future<bool> updateProfile(UserProfile profile, {bool optimistic = true}) async {
    return _updateProfileInternal(profile, optimistic: optimistic, isRetry: false, originalProfile: _profile);
  }

  Future<bool> _updateProfileInternal(UserProfile profile, {required bool optimistic, required bool isRetry, UserProfile? originalProfile}) async {
    if (optimistic && !isRetry) {
      _profile = profile;
      notifyListeners();
    }

    final token = _auth?.accessToken;
    if (token == null) {
      debugPrint('Update failed: Missing access token');
      if (optimistic) {
        _profile = originalProfile;
        notifyListeners();
      }
      return false;
    }

    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: profile.toJson(),
      );

      if (response.statusCode == 200) {
        _profile = UserProfile.fromJson(response.body);
        notifyListeners();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        debugPrint('Update profile unauthorized, attempting token refresh');
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _updateProfileInternal(profile, optimistic: optimistic, isRetry: true, originalProfile: originalProfile);
        } else {
          if (optimistic) {
            _profile = originalProfile;
            notifyListeners();
          }
          return false;
        }
      } else {
        debugPrint('Failed to update profile: ${response.statusCode} ${response.body}');
        if (optimistic) {
          _profile = originalProfile;
          notifyListeners();
        }
        return false;
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      if (optimistic) {
        _profile = originalProfile;
        notifyListeners();
      }
      return false;
    }
  }

  Future<void> toggleFavorite(int methodId) async {
    if (_profile == null) return;

    final updatedFavorites = List<int>.from(_profile!.favorites);
    if (updatedFavorites.contains(methodId)) {
      updatedFavorites.remove(methodId);
    } else {
      updatedFavorites.add(methodId);
    }

    final updatedProfile = _profile!.copyWith(favorites: updatedFavorites);
    await updateProfile(updatedProfile, optimistic: true);
  }

  bool isFavorite(int methodId) {
    return _profile?.favorites.contains(methodId) ?? false;
  }
}
