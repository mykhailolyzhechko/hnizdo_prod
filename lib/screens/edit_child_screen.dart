import 'package:flutter/material.dart';
import 'package:hnizdo/screens/child_form_screen.dart';

class EditChildScreen extends StatelessWidget {
  final String childId;

  const EditChildScreen({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return ChildFormScreen.edit(childId);
  }
}
