import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/participant.dart';
import 'auth_provider.dart';

class ParticipantProvider extends ChangeNotifier {
  AuthProvider? _auth;
  Map<String, List<WorkshopParticipant>> _workshopParticipants = {};
  bool _isLoading = false;

  ParticipantProvider(this._auth);

  List<WorkshopParticipant> getParticipants(String workshopId) => _workshopParticipants[workshopId] ?? [];
  bool get isLoading => _isLoading;

  String _baseUrl(String workshopId) => 'https://www.pramari.de/coach/api/v1/workshops/$workshopId/participants';

  void updateAuth(AuthProvider? auth) {
    _auth = auth;
  }

  Future<void> fetchParticipants(String workshopId, {bool isRetry = false}) async {
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
        _workshopParticipants[workshopId] = data.map((item) => WorkshopParticipant.fromJson(item)).toList();
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await fetchParticipants(workshopId, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error fetching participants: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addParticipant(WorkshopParticipant participant) async {
    return _addParticipantInternal(participant, isRetry: false);
  }

  Future<bool> _addParticipantInternal(WorkshopParticipant participant, {required bool isRetry}) async {
    final token = _auth?.accessToken;
    if (token == null) return false;

    try {
      final response = await http.post(
        Uri.parse('${_baseUrl(participant.workshop)}/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(participant.toJson()..remove('id')),
      );

      if (response.statusCode == 201) {
        final newParticipant = WorkshopParticipant.fromJson(jsonDecode(response.body));
        _workshopParticipants[participant.workshop] = [...getParticipants(participant.workshop), newParticipant];
        notifyListeners();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _addParticipantInternal(participant, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error adding participant: $e');
    }
    return false;
  }

  Future<bool> deleteParticipant(String workshopId, String participantId) async {
    return _deleteParticipantInternal(workshopId, participantId, isRetry: false);
  }

  Future<bool> _deleteParticipantInternal(String workshopId, String participantId, {required bool isRetry}) async {
    final token = _auth?.accessToken;
    if (token == null) return false;

    try {
      final response = await http.delete(
        Uri.parse('${_baseUrl(workshopId)}/$participantId/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 204) {
        _workshopParticipants[workshopId]?.removeWhere((p) => p.id == participantId);
        notifyListeners();
        return true;
      } else if (response.statusCode == 401 && !isRetry) {
        final refreshed = await _auth?.refresh() ?? false;
        if (refreshed) {
          return await _deleteParticipantInternal(workshopId, participantId, isRetry: true);
        }
      }
    } catch (e) {
      debugPrint('Error deleting participant: $e');
    }
    return false;
  }
}
