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
        "method_type": "Discovery",
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
      expect(method.methodType, "Discovery");
      expect(method.accentColor, Colors.blue);
    });

    test('Method.accentColor returns correct colors for types', () {
      final methodDiscovery = Method(
        id: 1, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'Discovery'
      );
      expect(methodDiscovery.accentColor, Colors.blue);

      final methodDefinition = Method(
        id: 2, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'Definition'
      );
      expect(methodDefinition.accentColor, Colors.green);

      final methodDevelopment = Method(
        id: 3, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'Development'
      );
      expect(methodDevelopment.accentColor, Colors.orange);

      final methodDelivery = Method(
        id: 4, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'Delivery'
      );
      expect(methodDelivery.accentColor, Colors.purple);

      final methodUnknown = Method(
        id: 5, title: 'T', benefit: 'B', methodInput: 'I', methodOutput: 'O',
        why: 'W', how: 'H', tags: [], methodType: 'Unknown'
      );
      expect(methodUnknown.accentColor, const Color(0xFF25AFF4));
    });
  });
}
