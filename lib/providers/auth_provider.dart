import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openid_client/openid_client_io.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthProvider extends ChangeNotifier {
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
    if (key == 'OAUTH_CLIENT_ID' && const bool.hasEnvironment('OAUTH_CLIENT_ID')) {
      return const String.fromEnvironment('OAUTH_CLIENT_ID');
    }
    if (key == 'OAUTH_REDIRECT_URL' && const bool.hasEnvironment('OAUTH_REDIRECT_URL')) {
      return const String.fromEnvironment('OAUTH_REDIRECT_URL');
    }
    if (key == 'OAUTH_DISCOVERY_URL' && const bool.hasEnvironment('OAUTH_DISCOVERY_URL')) {
      return const String.fromEnvironment('OAUTH_DISCOVERY_URL');
    }
    if (key == 'OAUTH_CLIENT_SECRET' && const bool.hasEnvironment('OAUTH_CLIENT_SECRET')) {
      return const String.fromEnvironment('OAUTH_CLIENT_SECRET');
    }
    return null;
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

      var issuer = await Issuer.discover(Uri.parse(_getConfigValue('OAUTH_DISCOVERY_URL')!));
      var client = Client(issuer, _getConfigValue('OAUTH_CLIENT_ID')!);

      final redirectUri = Uri.parse(_getConfigValue('OAUTH_REDIRECT_URL')!);

      // Authenticator spins up a local web server to catch the redirect (Best for macOS/Desktop)
      var authenticator = Authenticator(
        client,
        scopes: ['openid', 'profile', 'email', 'offline_access'],
        port: redirectUri.port > 0 ? redirectUri.port : 4000,
        urlLancher: (String url) async {
          if (await canLaunchUrl(Uri.parse(url))) {
            await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
          } else {
            throw 'Could not launch $url';
          }
        },
      );

      var credential = await authenticator.authorize();
      var tokenResponse = await credential.getTokenResponse();

      _accessToken = tokenResponse.accessToken;
      _idToken = tokenResponse.idToken.toCompactSerialization();
      _refreshToken = tokenResponse.refreshToken;

      await _secureStorage.write(key: 'access_token', value: _accessToken);
      await _secureStorage.write(key: 'id_token', value: _idToken);
      await _secureStorage.write(key: 'refresh_token', value: _refreshToken);

      _isAuthenticated = true;
      notifyListeners();
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

      var issuer = await Issuer.discover(Uri.parse(_getConfigValue('OAUTH_DISCOVERY_URL')!));
      var client = Client(issuer, _getConfigValue('OAUTH_CLIENT_ID')!);

      var credential = client.createCredential(
        refreshToken: _refreshToken,
      );

      var tokenResponse = await credential.getTokenResponse(true);

      _accessToken = tokenResponse.accessToken;
      _idToken = tokenResponse.idToken.toCompactSerialization();
      _refreshToken = tokenResponse.refreshToken;

      await _secureStorage.write(key: 'access_token', value: _accessToken);
      await _secureStorage.write(key: 'id_token', value: _idToken);
      await _secureStorage.write(key: 'refresh_token', value: _refreshToken);

      notifyListeners();
    } catch (e) {
      debugPrint('Refresh token error: $e');
      await logout();
    }
  }
}
