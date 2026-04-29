import 'package:flutter_test/flutter_test.dart';
import 'package:coach/models/workshop.dart';
import 'dart:convert';

void main() {
  group('Workshop Model Parsing Tests', () {
    test('Workshop.fromJson should handle DRF response with start_date', () {
      final json = {
        "id": "a49ece05-220e-4b53-a431-745ea8d225a4",
        "title": "One.",
        "description": "",
        "owner": {
          "id": 1,
          "username": "andreas_7419023a",
          "first_name": "Andreas",
          "last_name": "Neumeier",
          "email": "andreas@neumeier.org"
        },
        "location_type": "virtual",
        "workshop_type": "design-thinking",
        "start_date": "2026-04-28T10:34:59.149349Z",
        "end_date": null,
        "participant_count": 0,
        "session_count": 0,
        "created_at": "2026-04-28T10:34:59.149349Z",
        "updated_at": "2026-04-28T10:34:59.149384Z"
      };

      final workshop = Workshop.fromJson(json);

      expect(workshop.id, "a49ece05-220e-4b53-a431-745ea8d225a4");
      expect(workshop.title, "One.");
      expect(workshop.date, DateTime.parse("2026-04-28T10:34:59.149349Z"));
      expect(workshop.locationMode, LocationMode.virtual);
    });

    test('Workshop.fromJson should handle null fields and missing duration', () {
      final json = {
        "id": "a49ece05-220e-4b53-a431-745ea8d225a4",
        "title": "One.",
        "location_type": null,
        "start_date": null,
      };

      final workshop = Workshop.fromJson(json);

      expect(workshop.id, "a49ece05-220e-4b53-a431-745ea8d225a4");
      expect(workshop.locationMode, LocationMode.virtual); // Default
      expect(workshop.durationValue, 0); // Default
    });
  });

  group('Workshop Pagination Parsing Logic', () {
    test('Should extract results from DRF paginated response', () {
      final String responseBody = '{"count":1,"next":null,"previous":null,"results":[{"id":"a49ece05-220e-4b53-a431-745ea8d225a4","title":"One.","location_type":"virtual"}]}';

      final dynamic decodedData = jsonDecode(responseBody);
      final List<dynamic> data = (decodedData is Map && decodedData.containsKey('results'))
          ? decodedData['results']
          : decodedData;

      expect(data, isA<List>());
      expect(data.length, 1);
      expect(data[0]['title'], "One.");
    });

    test('Should handle non-paginated list response', () {
      final String responseBody = '[{"id":"1","title":"One"}]';

      final dynamic decodedData = jsonDecode(responseBody);
      final List<dynamic> data = (decodedData is Map && decodedData.containsKey('results'))
          ? decodedData['results']
          : decodedData;

      expect(data, isA<List>());
      expect(data.length, 1);
      expect(data[0]['title'], "One");
    });
  });
}
