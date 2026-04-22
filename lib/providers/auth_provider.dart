import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  bool _isAuthenticated = false;
  oauth2.Client? _client;

  bool get isAuthenticated => _isAuthenticated;
  String? get accessToken => _client?.credentials.accessToken;
  oauth2.Client? get client => _client;

  AuthProvider() {
    _loadTokens();
  }

  Future<void> _loadTokens() async {
    try {
      final credentialsJson = await _secureStorage.read(key: 'oauth_credentials');
      if (credentialsJson != null) {
        final credentials = oauth2.Credentials.fromJson(credentialsJson);
        _client = oauth2.Client(
          credentials,
          identifier: _getConfigValue('OAUTH_CLIENT_ID') ?? '',
          secret: _getConfigValue('OAUTH_CLIENT_SECRET'),
        );
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
    if (key == 'OAUTH_AUTHORIZATION_ENDPOINT' && const bool.hasEnvironment('OAUTH_AUTHORIZATION_ENDPOINT')) {
      return const String.fromEnvironment('OAUTH_AUTHORIZATION_ENDPOINT');
    }
    if (key == 'OAUTH_TOKEN_ENDPOINT' && const bool.hasEnvironment('OAUTH_TOKEN_ENDPOINT')) {
      return const String.fromEnvironment('OAUTH_TOKEN_ENDPOINT');
    }
    if (key == 'OAUTH_CLIENT_SECRET' && const bool.hasEnvironment('OAUTH_CLIENT_SECRET')) {
      return const String.fromEnvironment('OAUTH_CLIENT_SECRET');
    }
    return null;
  }

  void _validateEnv() {
    final clientId = _getConfigValue('OAUTH_CLIENT_ID');
    final redirectUrl = _getConfigValue('OAUTH_REDIRECT_URL');
    final authEndpoint = _getConfigValue('OAUTH_AUTHORIZATION_ENDPOINT');
    final tokenEndpoint = _getConfigValue('OAUTH_TOKEN_ENDPOINT');

    if (clientId == null || clientId.isEmpty) throw Exception('OAUTH_CLIENT_ID is not defined');
    if (redirectUrl == null || redirectUrl.isEmpty) throw Exception('OAUTH_REDIRECT_URL is not defined');
    if (authEndpoint == null || authEndpoint.isEmpty) throw Exception('OAUTH_AUTHORIZATION_ENDPOINT is not defined');
    if (tokenEndpoint == null || tokenEndpoint.isEmpty) throw Exception('OAUTH_TOKEN_ENDPOINT is not defined');
  }

  Future<void> login() async {
    try {
      _validateEnv();

      final identifier = _getConfigValue('OAUTH_CLIENT_ID')!;
      final secret = _getConfigValue('OAUTH_CLIENT_SECRET');
      final authorizationEndpoint = Uri.parse(_getConfigValue('OAUTH_AUTHORIZATION_ENDPOINT')!);
      final tokenEndpoint = Uri.parse(_getConfigValue('OAUTH_TOKEN_ENDPOINT')!);
      final redirectUrl = Uri.parse('http://${_getConfigValue('OAUTH_REDIRECT_URL')!}');

      var grant = oauth2.AuthorizationCodeGrant(
        identifier,
        authorizationEndpoint,
        tokenEndpoint,
        secret: secret,
      );

      var authorizationUrl = grant.getAuthorizationUrl(
        redirectUrl,
        scopes: ['openid', 'profile', 'email', 'offline_access'],
      );

      await _redirect(authorizationUrl);

      var responseUrl = await _listenForRedirect(redirectUrl);

      _client = await grant.handleAuthorizationResponse(responseUrl.queryParameters);

      final credentialsJson = _client!.credentials.toJson();
      await _secureStorage.write(key: 'oauth_credentials', value: credentialsJson);

      _isAuthenticated = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Login error: $e');
      rethrow;
    }
  }

  Future<void> _redirect(Uri authorizationUrl) async {
    if (await canLaunchUrl(authorizationUrl)) {
      await launchUrl(authorizationUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $authorizationUrl';
    }
  }

  Future<Uri> _listenForRedirect(Uri redirectUrl) async {
    var server = await HttpServer.bind(redirectUrl.host, redirectUrl.port);
    var request = await server.first;
    var responseUrl = request.uri;

    request.response
      ..statusCode = 200
      ..headers.set('Content-Type', 'text/html; charset=utf-8')
      ..write('<html><body><h1>Authentication Successful</h1><p>You can close this window and return to the app.</p></body></html>')
      ..close();
    
    await server.close();
    return responseUrl;
  }

  Future<void> logout() async {
    _client = null;
    _isAuthenticated = false;

    try {
      await _secureStorage.delete(key: 'oauth_credentials');
    } catch (e) {
      debugPrint('Error clearing tokens during logout: $e');
    }

    notifyListeners();
  }

  Future<void> refresh() async {
    if (_client == null || _client!.credentials.refreshToken == null) return;

    try {
      _validateEnv();
      _client = await _client!.refreshCredentials();

      final credentialsJson = _client!.credentials.toJson();
      await _secureStorage.write(key: 'oauth_credentials', value: credentialsJson);

      notifyListeners();
    } catch (e) {
      debugPrint('Refresh token error: $e');
      await logout();
    }
  }
}
