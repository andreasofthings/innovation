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
  });

  factory Method.fromJson(Map<String, dynamic> json) {
    // Wagtail might return fields as HTML strings, we might need to strip them later
    // but for now we keep them as is or use a simple regex if they are consistently <p>...

    String stripHtml(String htmlString) {
      return htmlString.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();
    }

    final meta = json['meta'] as Map<String, dynamic>?;
    final parent = meta?['parent'] as Map<String, dynamic>?;

    return Method(
      id: json['id'],
      title: json['title'] ?? '',
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      benefit: stripHtml(json['benefit'] ?? ''),
      methodInput: stripHtml(json['method_input'] ?? ''),
      methodOutput: stripHtml(json['method_output'] ?? ''),
      why: stripHtml(json['why'] ?? ''),
      how: stripHtml(json['how'] ?? ''),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      methodType: json['method_type'] ?? 'Unknown',
      parentTitle: parent?['title'],
    );
  }

  Color get accentColor {
    switch (methodType.toLowerCase()) {
      case 'discovery':
        return Colors.blue;
      case 'definition':
        return Colors.green;
      case 'development':
        return Colors.orange;
      case 'delivery':
        return Colors.purple;
      default:
        return const Color(0xFF25AFF4); // Default theme color
    }
  }
}
