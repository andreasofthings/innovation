import 'dart:convert';

class UserProfile {
  final int? pk;
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
  final Map<String, dynamic> rawAttributes;

  UserProfile({
    this.pk,
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
    this.rawAttributes = const {},
  });

  UserProfile copyWith({
    int? pk,
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
    Map<String, dynamic>? rawAttributes,
  }) {
    return UserProfile(
      pk: pk ?? this.pk,
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
      rawAttributes: rawAttributes ?? this.rawAttributes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pk': pk,
      'name': name,
      'email': email,
      'attributes': {
        ...rawAttributes,
        'coach_language': language,
        'coach_confidence': confidence,
        'coach_defaultWorkshopLength': defaultWorkshopLength,
        'coach_defaultWorkshopSetting': defaultWorkshopSetting,
        'coach_defaultGroupSize': defaultGroupSize,
        'coach_isGoogleConnected': isGoogleConnected,
        'coach_color': color,
        'coach_icon': icon,
        'coach_dateOfBirth': dateOfBirth?.toIso8601String(),
        'coach_country': country,
      }
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Handling Authentik Core User API response
    final int? pk = map['pk'];
    final String name = map['name'] ?? map['username'] ?? map['preferred_username'] ?? 'User';
    final String email = map['email'] ?? '';

    // Custom attributes in Authentik
    final attributes = map['attributes'] ?? {};

    return UserProfile(
      pk: pk,
      language: attributes['coach_language'] ?? attributes['language'] ?? map['language'] ?? 'en',
      confidence: (attributes['coach_confidence'] ?? attributes['confidence'] ?? map['confidence'] ?? 0.5).toDouble(),
      defaultWorkshopLength: attributes['coach_defaultWorkshopLength'] ?? attributes['defaultWorkshopLength'] ?? map['defaultWorkshopLength'] ?? 60,
      defaultWorkshopSetting: attributes['coach_defaultWorkshopSetting'] ?? attributes['defaultWorkshopSetting'] ?? map['defaultWorkshopSetting'] ?? 'on-site',
      defaultGroupSize: attributes['coach_defaultGroupSize'] ?? attributes['defaultGroupSize'] ?? map['defaultGroupSize'] ?? 10,
      isGoogleConnected: attributes['coach_isGoogleConnected'] ?? attributes['isGoogleConnected'] ?? map['isGoogleConnected'] ?? false,
      color: attributes['coach_color'] ?? attributes['color'] ?? map['color'] ?? '#25AFF4',
      icon: attributes['coach_icon'] ?? attributes['icon'] ?? map['icon'] ?? 'person',
      dateOfBirth: (attributes['coach_dateOfBirth'] ?? attributes['dateOfBirth'] ?? map['dateOfBirth']) != null
          ? DateTime.tryParse(attributes['coach_dateOfBirth'] ?? attributes['dateOfBirth'] ?? map['dateOfBirth'])
          : null,
      country: attributes['coach_country'] ?? attributes['country'] ?? map['country'] ?? '',
      name: name,
      email: email,
      rawAttributes: attributes is Map<String, dynamic> ? Map<String, dynamic>.from(attributes) : {},
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
