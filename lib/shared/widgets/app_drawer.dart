import 'package:flutter/material.dart';
import 'package:focus/features/settings/viewmodels/theme_view_model.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/shared/utils/logout.dart';
import 'package:focus/shared/widgets/app_version.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeVM = context.watch<ThemeViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final isDark = themeVM.isDarkMode;
    final userName = authVM.userName ?? 'Usuário';
    final userEmail = authVM.userEmail ?? '';
    final initial = userName.trim().isEmpty ? 'U' : userName[0].toUpperCase();

    return Drawer(
      child: Column(
        children: [
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
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDark ? "Modo Claro" : "Modo Noturno"),
            trailing: Switch(
              value: isDark,
              onChanged: (value) => themeVM.toggleTheme(),
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => logout(context, authVM),
          ),
          const Spacer(),
          const Padding(padding: EdgeInsets.all(16.0), child: AppVersion()),
        ],
      ),
    );
  }
}
