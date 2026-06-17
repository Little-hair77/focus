import 'package:flutter/material.dart';

/// Cria a decoração padrão usada nos campos de formulário do app.
InputDecoration appInputDecoration(
  BuildContext context, {
  required String label,
  required IconData icon,
}) {
  final primary = Theme.of(context).colorScheme.primary;
  return InputDecoration(
    labelText: label,
    prefixIcon: ExcludeSemantics(
      child: Icon(icon, color: primary.withValues(alpha: 0.7)),
    ),
  );
}
