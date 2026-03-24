import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterAppAuth _appAuth = const FlutterAppAuth();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  String? _accessToken;
  String? _idToken;
  String? _refreshToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;

  AuthProvider() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    try {
      _accessToken = await _secureStorage.read(key: 'access_token');
      _idToken = await _secureStorage.read(key: 'id_token');
      _refreshToken = await _secureStorage.read(key: 'refresh_token');

      if (_accessToken != null) {
        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading tokens from secure storage: $e');
    }
  }

  String? _getConfigValue(String key) {
    return dotenv.env[key];
  }

  void _validateEnv() {
    final clientId = _getConfigValue('OAUTH_CLIENT_ID');
    final redirectUrl = _getConfigValue('OAUTH_REDIRECT_URL');
    final discoveryUrl = _getConfigValue('OAUTH_DISCOVERY_URL');

    if (clientId == null || clientId.isEmpty) {
      throw Exception('OAUTH_CLIENT_ID is not defined');
    }
    if (redirectUrl == null || redirectUrl.isEmpty) {
      throw Exception('OAUTH_REDIRECT_URL is not defined');
    }
    if (discoveryUrl == null || discoveryUrl.isEmpty) {
      throw Exception('OAUTH_DISCOVERY_URL is not defined');
    }
  }

  Future<void> login() async {
    try {
      _validateEnv();

      final AuthorizationTokenResponse result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _getConfigValue('OAUTH_CLIENT_ID')!,
          _getConfigValue('OAUTH_REDIRECT_URL')!,
          clientSecret: _getConfigValue('OAUTH_CLIENT_SECRET'),
          discoveryUrl: _getConfigValue('OAUTH_DISCOVERY_URL'),
          scopes: ['openid', 'profile', 'email', 'offline_access'],
          promptValues: ['login'],
        ),
      );

      await _processAuthTokenResponse(result);
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> _processAuthTokenResponse(AuthorizationTokenResponse response) async {
    _accessToken = response.accessToken;
    _idToken = response.idToken;
    _refreshToken = response.refreshToken;

    await _secureStorage.write(key: 'access_token', value: _accessToken);
    await _secureStorage.write(key: 'id_token', value: _idToken);
    await _secureStorage.write(key: 'refresh_token', value: _refreshToken);

    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    _idToken = null;
    _refreshToken = null;
    _isAuthenticated = false;

    try {
      await _secureStorage.delete(key: 'access_token');
      await _secureStorage.delete(key: 'id_token');
      await _secureStorage.delete(key: 'refresh_token');
    } catch (e) {
      debugPrint('Error clearing tokens during logout: $e');
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    if (_refreshToken == null) return;

    try {
      _validateEnv();

      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          _getConfigValue('OAUTH_CLIENT_ID')!,
          _getConfigValue('OAUTH_REDIRECT_URL')!,
          clientSecret: _getConfigValue('OAUTH_CLIENT_SECRET'),
          discoveryUrl: _getConfigValue('OAUTH_DISCOVERY_URL'),
          refreshToken: _refreshToken,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

        _accessToken = result.accessToken;
        _idToken = result.idToken;
        _refreshToken = result.refreshToken;

        await _secureStorage.write(key: 'access_token', value: _accessToken);
        await _secureStorage.write(key: 'id_token', value: _idToken);
        await _secureStorage.write(key: 'refresh_token', value: _refreshToken);

        notifyListeners();
    } catch (e) {
      debugPrint('Refresh token error: $e');
      // If refresh fails, we might want to log the user out
      await logout();
    }
  }
}
