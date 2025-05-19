import 'package:flutter/material.dart';

class ChildDetailsScreen extends StatelessWidget {
  final String childId;

  const ChildDetailsScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Child Details')),
      body: Center(child: Text('Details for Child ID: $childId')),
    );
  }
}