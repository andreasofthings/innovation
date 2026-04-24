import 'package:flutter_test/flutter_test.dart';
import 'package:coach/models/method.dart';
import 'package:flutter/material.dart';

void main() {
  group('Method Model Tests', () {
    test('Method.fromJson handles Wagtail response and strips HTML', () {
      final json = {
        "id": 1,
        "title": "Test Method",
        "date": "2024-01-01",
        "benefit": "<p>Good benefit</p>",
        "method_input": "Input",
        "method_output": "Output",
        "why": "Why",
        "how": "How",
        "tags": ["tag1", "tag2"],
        "method_type": "warmup",
        "meta": {
          "parent": {"title": "Parent Category"}
        }
      };

      final method = Method.fromJson(json);

      expect(method.id, 1);
      expect(method.title, "Test Method");
      expect(method.benefit, "Good benefit");
      expect(method.tags, contains("tag1"));
      expect(method.parentTitle, "Parent Category");
      expect(method.methodType, "warmup");
      expect(method.accentColor, Colors.amber);
      expect(method.icon, Icons.groups);
    });

    test('Method.accentColor and icon return correct values for types', () {
      final warmup = Method(
        id: 1, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'warmup'
      );
      expect(warmup.accentColor, Colors.amber);
      expect(warmup.icon, Icons.groups);

      final empathize = Method(
        id: 2, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'empathize'
      );
      expect(empathize.accentColor, Colors.orange);
      expect(empathize.icon, Icons.help_outline);

      final define = Method(
        id: 3, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'define'
      );
      expect(define.accentColor, Colors.redAccent);
      expect(define.icon, Icons.architecture);

      final ideate = Method(
        id: 4, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'ideate'
      );
      expect(ideate.accentColor, Colors.green);
      expect(ideate.icon, Icons.lightbulb_outline);

      final prototype = Method(
        id: 5, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'prototype'
      );
      expect(prototype.accentColor, const Color(0xFF25AFF4));
      expect(prototype.icon, Icons.directions_car);

      final unknown = Method(
        id: 6, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'Unknown'
      );
      expect(unknown.accentColor, const Color(0xFF25AFF4));
      expect(unknown.icon, Icons.help_outline);
    });
  });
}
