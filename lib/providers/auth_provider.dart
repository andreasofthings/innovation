import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_appauth/flutter_appauth.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final FlutterAppAuth _appAuth = const FlutterAppAuth();

  bool _isAuthenticated = false;
  String? _accessToken;
  String? _idToken;
  String? _refreshToken;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _accessToken;
  String? get idToken => _idToken;

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
    switch (key) {
      case 'OAUTH_CLIENT_ID':
        return const String.fromEnvironment('OAUTH_CLIENT_ID');
      case 'OAUTH_REDIRECT_URL':
        return const String.fromEnvironment('OAUTH_REDIRECT_URL', defaultValue: 'https://innovation.pramari.de/');
      case 'OAUTH_DISCOVERY_URL':
        return const String.fromEnvironment('OAUTH_DISCOVERY_URL', defaultValue: 'https://id.pramari.de/application/o/innovation/.well-known/openid-configuration');
      default:
        return null;
    }
  }

  void _validateEnv() {
    final clientId = _getConfigValue('OAUTH_CLIENT_ID');
    if (clientId == null || clientId.isEmpty) {
      throw Exception('OAUTH_CLIENT_ID is not defined. Please build with --dart-define=OAUTH_CLIENT_ID=...');
    }
  }

  Future<void> login() async {
    try {
      _validateEnv();

      final clientId = _getConfigValue('OAUTH_CLIENT_ID')!;
      final redirectUrl = _getConfigValue('OAUTH_REDIRECT_URL')!;
      final discoveryUrl = _getConfigValue('OAUTH_DISCOVERY_URL')!;

      debugPrint('Starting login with clientId: $clientId, redirectUrl: $redirectUrl');

      final AuthorizationTokenResponse? result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          discoveryUrl: discoveryUrl,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      if (result != null) {
        _accessToken = result.accessToken;
        _idToken = result.idToken;
        _refreshToken = result.refreshToken;

        await _secureStorage.write(key: 'access_token', value: _accessToken);
        await _secureStorage.write(key: 'id_token', value: _idToken);
        await _secureStorage.write(key: 'refresh_token', value: _refreshToken);

        _isAuthenticated = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
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
      final clientId = _getConfigValue('OAUTH_CLIENT_ID')!;
      final redirectUrl = _getConfigValue('OAUTH_REDIRECT_URL')!;
      final discoveryUrl = _getConfigValue('OAUTH_DISCOVERY_URL')!;

      final TokenResponse? result = await _appAuth.token(
        TokenRequest(
          clientId,
          redirectUrl,
          discoveryUrl: discoveryUrl,
          refreshToken: _refreshToken,
          scopes: ['openid', 'profile', 'email', 'offline_access'],
        ),
      );

      if (result != null) {
        _accessToken = result.accessToken;
        _idToken = result.idToken;
        _refreshToken = result.refreshToken;

        await _secureStorage.write(key: 'access_token', value: _accessToken);
        await _secureStorage.write(key: 'id_token', value: _idToken);
        await _secureStorage.write(key: 'refresh_token', value: _refreshToken);

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Refresh token error: $e');
      await logout();
    }
  }
}
