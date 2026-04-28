import 'dart:convert';

class WorkshopSession {
  final String id;
  final String workshop; // workshop ID
  final String title;
  final String description;
  final int order;
  final int? methodPage; // method ID
  final DateTime? startTime;
  final int durationMinutes;

  WorkshopSession({
    required this.id,
    required this.workshop,
    required this.title,
    this.description = '',
    this.order = 0,
    this.methodPage,
    this.startTime,
    this.durationMinutes = 60,
  });

  factory WorkshopSession.fromJson(Map<String, dynamic> json) {
    return WorkshopSession(
      id: json['id']?.toString() ?? '',
      workshop: json['workshop']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      order: json['order'] ?? 0,
      methodPage: json['method_page'],
      startTime: json['start_time'] != null ? DateTime.tryParse(json['start_time']) : null,
      durationMinutes: json['duration_minutes'] ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'workshop': workshop,
      'title': title,
      'description': description,
      'order': order,
      'method_page': methodPage,
      'start_time': startTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
    };
  }
}
