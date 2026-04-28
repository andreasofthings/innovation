import 'package:flutter_test/flutter_test.dart';
import 'package:coach/models/workshop.dart';

void main() {
  group('Workshop Model Tests', () {
    test('Workshop.fromJson should parse correctly', () {
      final json = {
        'id': '123',
        'title': 'Test Workshop',
        'location_type': 'on-site',
        'workshop_type': 'design-thinking',
        'status': 'planned',
        'scheduled_at': '2023-12-01T10:00:00Z',
        'duration_value': 90,
        'duration_unit': 'minutes',
        'participant_count': 12,
      };

      final workshop = Workshop.fromJson(json);

      expect(workshop.id, '123');
      expect(workshop.title, 'Test Workshop');
      expect(workshop.locationMode, LocationMode.onSite);
      expect(workshop.workshopType, 'design-thinking');
      expect(workshop.durationValue, 90);
      expect(workshop.durationUnit, DurationUnit.minutes);
      expect(workshop.participantCount, 12);
    });

    test('Workshop.toJson should create correct map', () {
      final workshop = Workshop(
        id: '456',
        title: 'Another Workshop',
        locationMode: LocationMode.virtual,
        status: WorkshopStatus.delivered,
        date: DateTime.parse('2023-11-20T14:00:00Z'),
        durationValue: 2,
        durationUnit: DurationUnit.hours,
        participantCount: 5,
      );

      final json = workshop.toJson();

      expect(json['id'], '456');
      expect(json['location_type'], 'virtual');
      expect(json['status'], 'delivered');
      expect(json['duration_value'], 2);
      expect(json['duration_unit'], 'hours');
    });
  });
}
