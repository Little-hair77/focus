import 'package:flutter/material.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/features/auth/views/login.dart';
import 'package:provider/provider.dart';

/// Decide se o usuário vê a tela autenticada ou a tela de login.
class AuthGate extends StatelessWidget {
  /// Tela exibida quando a sessão já está autenticada.
  final Widget authenticatedScreen;

  const AuthGate({super.key, required this.authenticatedScreen});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    if (!authVM.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return authVM.isLoggedIn ? authenticatedScreen : const LoginPage();
  }
}
