import 'package:flutter/material.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/shared/utils/logout.dart';
import 'package:focus/shared/widgets/app_version.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authVM = context.watch<AuthViewModel>();
    final userName = authVM.userName ?? 'Usuário';
    final userEmail = authVM.userEmail ?? '';
    final initial = userName.trim().isEmpty ? 'U' : userName[0].toUpperCase();

    void navigateTo(String routeName) {
      Navigator.of(context).pop(); 
      Navigator.of(context).pushNamed(routeName);
    }

    return Drawer(
      child: Column(
        children: [
          // Cabeçalho com dados do Usuário
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            accountName: Text(
              userName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(userEmail),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.onPrimary,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 24,
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Menu de Opções Enxuto e Clean
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // Link Direto para o Modo Foco Geral
                ListTile(
                  leading: const Icon(Icons.hourglass_empty_rounded, color: Colors.amber),
                  title: const Text(
                    'Modo Foco',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  onTap: () => navigateTo('/focus'),
                ),

                // Configurações do Aplicativo (Para centralizar Tema e mais ajustes futuros)
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Configurações'),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          // Ação de Logout isolada na base
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Sair', style: TextStyle(color: Colors.redAccent)),
            onTap: () => logout(context, authVM),
          ),
          
          // Versão do Aplicativo no Rodapé
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: AppVersion(),
          ),
        ],
      ),
    );
  }
}