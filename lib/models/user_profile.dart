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
      'name': name,
      'email': email,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Handling Authentik/OIDC standard claims and custom attributes
    final String name = map['name'] ?? map['preferred_username'] ?? 'User';
    final String email = map['email'] ?? '';

    // Custom attributes in Authentik are often under 'attributes' key or flattened
    final attributes = map['attributes'] ?? {};

    return UserProfile(
      language: attributes['language'] ?? map['language'] ?? 'en',
      confidence: (attributes['confidence'] ?? map['confidence'] ?? 0.5).toDouble(),
      defaultWorkshopLength: attributes['defaultWorkshopLength'] ?? map['defaultWorkshopLength'] ?? 60,
      defaultWorkshopSetting: attributes['defaultWorkshopSetting'] ?? map['defaultWorkshopSetting'] ?? 'on-site',
      defaultGroupSize: attributes['defaultGroupSize'] ?? map['defaultGroupSize'] ?? 10,
      isGoogleConnected: attributes['isGoogleConnected'] ?? map['isGoogleConnected'] ?? false,
      color: attributes['color'] ?? map['color'] ?? '#25AFF4',
      icon: attributes['icon'] ?? map['icon'] ?? 'person',
      dateOfBirth: (attributes['dateOfBirth'] ?? map['dateOfBirth']) != null
          ? DateTime.parse(attributes['dateOfBirth'] ?? map['dateOfBirth'])
          : null,
      country: attributes['country'] ?? map['country'] ?? '',
      name: name,
      email: email,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
