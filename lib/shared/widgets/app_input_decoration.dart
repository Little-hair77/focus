import 'package:flutter/material.dart';

InputDecoration appInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
}) {
  final primary = Theme.of(context).colorScheme.primary;
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: primary.withValues(alpha: 0.7)),
  );
}
