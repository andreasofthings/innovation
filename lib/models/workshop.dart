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

  static LocationMode fromJson(dynamic value) {
    if (value == null) return LocationMode.virtual;
    final String val = value.toString().toLowerCase();
    switch (val) {
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
    // Determine date: prefer start_date, then scheduled_at
    String? dateStr = json['start_date']?.toString() ?? json['scheduled_at']?.toString();
    DateTime parsedDate = DateTime.now();
    if (dateStr != null && dateStr.isNotEmpty) {
        parsedDate = DateTime.tryParse(dateStr) ?? DateTime.now();
    }

    // Determine status: if not provided, could infer from date?
    // For now, respect the provided status or default to planned.
    WorkshopStatus status = WorkshopStatus.planned;
    if (json['status'] == 'delivered') {
      status = WorkshopStatus.delivered;
    }

    return Workshop(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      locationMode: LocationMode.fromJson(json['location_type']),
      workshopType: json['workshop_type']?.toString() ?? 'design-thinking',
      status: status,
      date: parsedDate,
      durationValue: int.tryParse(json['duration_value']?.toString() ?? '0') ?? 0,
      durationUnit: _durationUnitFromString(json['duration_unit']?.toString() ?? 'minutes'),
      participantCount: int.tryParse(json['participant_count']?.toString() ?? '0') ?? 0,
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
