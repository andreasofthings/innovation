import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/session.dart';
import 'auth_provider.dart';

class SessionProvider extends ChangeNotifier {
  AuthProvider? _auth;
  Map<String, List<WorkshopSession>> _workshopSessions = {};
  bool _isLoading = false;

  SessionProvider(this._auth);

  List<WorkshopSession> getSessions(String workshopId) => _workshopSessions[workshopId] ?? [];
  bool get isLoading => _isLoading;

  String _baseUrl(String workshopId) => 'https://www.pramari.de/coach/api/v1/workshops/$workshopId/sessions';

  void updateAuth(AuthProvider? auth) {
    _auth = auth;
  }

  Future<void> fetchSessions(String workshopId, {bool isRetry = false}) async {
    final token = _auth?.accessToken;
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${_baseUrl(workshopId)}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        final List<dynamic> data = (decodedData is Map) ? (decodedData["results"] ?? decodedData["items"] ?? []) : decodedData;
        _workshopSessions[workshopId] = data.map((item) => WorkshopSession.fromJson(item)).toList();
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await fetchSessions(workshopId, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addSession(WorkshopSession session) async {
    return _addSessionInternal(session, isRetry: false);
  }

  Future<bool> _addSessionInternal(WorkshopSession session, {required bool isRetry}) async {
    final token = _auth?.accessToken;
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl(session.workshop)}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(session.toJson()..remove('id')),
      );

      if (response.statusCode == 201) {
        final newSession = WorkshopSession.fromJson(jsonDecode(response.body));
        _workshopSessions[session.workshop] = [...getSessions(session.workshop), newSession];
        notifyListeners();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _addSessionInternal(session, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error adding session: $e');
    }
    return false;
  }

  Future<bool> deleteSession(String workshopId, String sessionId) async {
    return _deleteSessionInternal(workshopId, sessionId, isRetry: false);
  }

  Future<bool> _deleteSessionInternal(String workshopId, String sessionId, {required bool isRetry}) async {
    final token = _auth?.accessToken;
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl(workshopId)}/$sessionId/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _workshopSessions[workshopId]?.removeWhere((s) => s.id == sessionId);
        notifyListeners();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _deleteSessionInternal(workshopId, sessionId, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error deleting session: $e');
    }
    return false;
  }
}
