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
  final String name;
  final String email;
  final List<int> favorites;

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
    required this.name,
    required this.email,
    this.favorites = const [],
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
    String? name,
    String? email,
    List<int>? favorites,
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
      name: name ?? this.name,
      email: email ?? this.email,
      favorites: favorites ?? this.favorites,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'language': language,
      'confidence': confidence,
      'default_workshop_length': defaultWorkshopLength,
      'default_workshop_setting': defaultWorkshopSetting,
      'default_group_size': defaultGroupSize,
      'is_google_connected': isGoogleConnected,
      'color': color,
      'icon': icon,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'country': country,
      'favorites': favorites,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      language: map['language'] ?? 'en',
      confidence: (map['confidence'] ?? 0.5).toDouble(),
      defaultWorkshopLength: map['default_workshop_length'] ?? 60,
      defaultWorkshopSetting: map['default_workshop_setting'] ?? 'on-site',
      defaultGroupSize: map['default_group_size'] ?? 10,
      isGoogleConnected: map['is_google_connected'] ?? false,
      color: map['color'] ?? '#25AFF4',
      icon: map['icon'] ?? 'person',
      dateOfBirth: map['date_of_birth'] != null ? DateTime.tryParse(map['date_of_birth']) : null,
      country: map['country'] ?? '',
      name: map['name'] ?? 'User',
      email: map['email'] ?? '',
      favorites: (map['favorites'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
