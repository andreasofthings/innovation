import 'package:flutter/material.dart';

class WorkshopScreen extends StatelessWidget {
  const WorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workshop')),
      body: const Center(child: Text('Workshop Screen')),
    );
  }
}
