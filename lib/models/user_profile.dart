import 'dart:convert';

class UserProfile {
  final String language;
  final double confidence;
  final int defaultWorkshopLength;
  final String defaultWorkshopSetting;
  final int defaultGroupSize;
  final bool isGoogleConnected;
  final String color; // Stored as Hex String
  final String icon;
  final DateTime? dateOfBirth;
  final String country;

  UserProfile({
    required this.language,
    required this.confidence,
    required this.defaultWorkshopLength,
    required this.defaultWorkshopSetting,
    required this.defaultGroupSize,
    required this.isGoogleConnected,
    required this.color,
    required this.icon,
    this.dateOfBirth,
    required this.country,
  });

  UserProfile copyWith({
    String? language,
    double? confidence,
    int? defaultWorkshopLength,
    String? defaultWorkshopSetting,
    int? defaultGroupSize,
    bool? isGoogleConnected,
    String? color,
    String? icon,
    DateTime? dateOfBirth,
    String? country,
  }) {
    return UserProfile(
      language: language ?? this.language,
      confidence: confidence ?? this.confidence,
      defaultWorkshopLength: defaultWorkshopLength ?? this.defaultWorkshopLength,
      defaultWorkshopSetting: defaultWorkshopSetting ?? this.defaultWorkshopSetting,
      defaultGroupSize: defaultGroupSize ?? this.defaultGroupSize,
      isGoogleConnected: isGoogleConnected ?? this.isGoogleConnected,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      country: country ?? this.country,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'confidence': confidence,
      'defaultWorkshopLength': defaultWorkshopLength,
      'defaultWorkshopSetting': defaultWorkshopSetting,
      'defaultGroupSize': defaultGroupSize,
      'isGoogleConnected': isGoogleConnected,
      'color': color,
      'icon': icon,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'country': country,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      language: map['language'] ?? 'en',
      confidence: (map['confidence'] ?? 0.5).toDouble(),
      defaultWorkshopLength: map['defaultWorkshopLength'] ?? 60,
      defaultWorkshopSetting: map['defaultWorkshopSetting'] ?? 'on-site',
      defaultGroupSize: map['defaultGroupSize'] ?? 10,
      isGoogleConnected: map['isGoogleConnected'] ?? false,
      color: map['color'] ?? '#25AFF4',
      icon: map['icon'] ?? 'person',
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      country: map['country'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
