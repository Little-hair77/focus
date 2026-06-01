import 'package:flutter/material.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';

Future<void> logout(BuildContext context, AuthViewModel authVM) async {
  await authVM.logout();
  if (!context.mounted) return;

  if (!authVM.isLoggedIn) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(authVM.errorMessage ?? 'Erro ao sair.')),
  );
}
