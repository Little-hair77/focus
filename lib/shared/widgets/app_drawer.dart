import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/settings/viewmodels/theme_view_model.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeVM = context.watch<ThemeViewModel>();
    final isDark = themeVM.isDarkMode;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: theme.colorScheme.primary),
            accountName: const Text(
              "Pablo Henrique",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text("Desenvolvedor"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: theme.colorScheme.onPrimary,
              child: Text(
                "P",
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
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Focus App v1.0",
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
