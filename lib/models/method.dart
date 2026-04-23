import 'package:flutter/material.dart';

class Method {
  final int id;
  final String title;
  final DateTime? date;
  final String benefit;
  final String methodInput;
  final String methodOutput;
  final String why;
  final String how;
  final List<String> tags;
  final String methodType;
  final String? parentTitle;
  final int? minPeople;
  final int? maxPeople;
  final int? minTime;
  final int? maxTime;

  Method({
    required this.id,
    required this.title,
    this.date,
    required this.benefit,
    required this.methodInput,
    required this.methodOutput,
    required this.why,
    required this.how,
    required this.tags,
    required this.methodType,
    this.parentTitle,
    this.minPeople,
    this.maxPeople,
    this.minTime,
    this.maxTime,
  });

  factory Method.fromJson(Map<String, dynamic> json) {
    // Wagtail might return fields as HTML strings, we might need to strip them later
    // but for now we keep them as is or use a simple regex if they are consistently <p>...

    String stripHtml(dynamic value) {
      final String htmlString = value?.toString() ?? '';
      return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
    }

    final meta = json['meta'] as Map<String, dynamic>?;
    final parent = meta?['parent'] as Map<String, dynamic>?;

    return Method(
      id: json['id'],
      title: json['title']?.toString() ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date'].toString()) : null,
      benefit: stripHtml(json['benefit']),
      methodInput: stripHtml(json['method_input']),
      methodOutput: stripHtml(json['method_output']),
      why: stripHtml(json['why']),
      how: stripHtml(json['how']),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      methodType: json['method_type']?.toString() ?? 'Unknown',
      parentTitle: parent?['title']?.toString(),
      minPeople: json['min_people'] as int?,
      maxPeople: json['max_people'] as int?,
      minTime: json['min_time'] as int?,
      maxTime: json['max_time'] as int?,
    );
  }

  Color get accentColor {
    switch (methodType.toLowerCase()) {
      case 'warmup':
        return Colors.white;
      case 'empathize':
        return const Color(0xFFE1F5FE); // Lightest blue
      case 'define':
        return const Color(0xFFB3E5FC); // Lighter blue
      case 'ideate':
        return const Color(0xFF4FC3F7); // Light blue
      case 'prototype':
        return const Color(0xFF25AFF4); // Primary blue
      default:
        return const Color(0xFF25AFF4); // Default theme color
    }
  }

  IconData get icon {
    switch (methodType.toLowerCase()) {
      case 'warmup':
        return Icons.groups;
      case 'empathize':
        return Icons.help_outline;
      case 'define':
        return Icons.architecture;
      case 'ideate':
        return Icons.lightbulb_outline;
      case 'prototype':
        return Icons.directions_car;
      default:
        return Icons.help_outline;
    }
  }
}
