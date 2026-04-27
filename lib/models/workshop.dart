enum LocationMode {
  virtual,
  onSite,
  hybrid;

  String get label {
    switch (this) {
      case LocationMode.virtual:
        return 'VIRTUAL';
      case LocationMode.onSite:
        return 'ON-SITE';
      case LocationMode.hybrid:
        return 'HYBRID';
    }
  }

  static LocationMode fromJson(String value) {
    switch (value.toLowerCase()) {
      case 'onsite':
      case 'on-site':
      case 'on_site':
        return LocationMode.onSite;
      case 'hybrid':
        return LocationMode.hybrid;
      case 'virtual':
      default:
        return LocationMode.virtual;
    }
  }

  String toJson() {
    switch (this) {
      case LocationMode.onSite:
        return 'on-site';
      case LocationMode.hybrid:
        return 'hybrid';
      case LocationMode.virtual:
        return 'virtual';
    }
  }
}

enum WorkshopStatus {
  planned,
  delivered;

  String get label {
    switch (this) {
      case WorkshopStatus.planned:
        return 'PLANNED';
      case WorkshopStatus.delivered:
        return 'DELIVERED';
    }
  }
}

enum DurationUnit {
  minutes,
  hours,
  days;

  String get label {
    switch (this) {
      case DurationUnit.minutes:
        return 'Minutes';
      case DurationUnit.hours:
        return 'Hours';
      case DurationUnit.days:
        return 'Days';
    }
  }
}

class Workshop {
  final String id;
  final String title;
  final LocationMode locationMode;
  final String workshopType;
  final WorkshopStatus status;
  final DateTime date;
  final int durationValue;
  final DurationUnit durationUnit;
  final int participantCount;

  Workshop({
    required this.id,
    required this.title,
    required this.locationMode,
    this.workshopType = 'design-thinking',
    required this.status,
    required this.date,
    required this.durationValue,
    required this.durationUnit,
    required this.participantCount,
  });

  factory Workshop.fromJson(Map<String, dynamic> json) {
    return Workshop(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      locationMode: LocationMode.fromJson(json['location_type'] ?? 'virtual'),
      workshopType: json['workshop_type'] ?? 'design-thinking',
      status: json['status'] == 'delivered' ? WorkshopStatus.delivered : WorkshopStatus.planned,
      date: DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      durationValue: json['duration_value'] ?? 0,
      durationUnit: _durationUnitFromString(json['duration_unit'] ?? 'minutes'),
      participantCount: json['participant_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location_type': locationMode.toJson(),
      'workshop_type': workshopType,
      'status': status == WorkshopStatus.delivered ? 'delivered' : 'planned',
      'scheduled_at': date.toIso8601String(),
      'duration_value': durationValue,
      'duration_unit': durationUnit.name,
      'participant_count': participantCount,
    };
  }

  static DurationUnit _durationUnitFromString(String value) {
    return DurationUnit.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => DurationUnit.minutes,
    );
  }
}
