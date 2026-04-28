import 'dart:convert';

class WorkshopParticipant {
  final String id;
  final String workshop; // workshop ID
  final String firstName;
  final String lastName;
  final String email;
  final String source;
  final String invitationStatus;
  final String? googleContactId;
  final DateTime? invitedAt;

  WorkshopParticipant({
    required this.id,
    required this.workshop,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.source = 'manual',
    this.invitationStatus = 'pending',
    this.googleContactId,
    this.invitedAt,
  });

  factory WorkshopParticipant.fromJson(Map<String, dynamic> json) {
    return WorkshopParticipant(
      id: json['id']?.toString() ?? '',
      workshop: json['workshop']?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      source: json['source'] ?? 'manual',
      invitationStatus: json['invitation_status'] ?? 'pending',
      googleContactId: json['google_contact_id'],
      invitedAt: json['invited_at'] != null ? DateTime.tryParse(json['invited_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'workshop': workshop,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'source': source,
      'invitation_status': invitationStatus,
      'google_contact_id': googleContactId,
      'invited_at': invitedAt?.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
