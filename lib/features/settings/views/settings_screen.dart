import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/settings/viewmodels/theme_view_model.dart';
import 'package:focus/shared/widgets/app_bar.dart';
import 'package:focus/shared/widgets/app_card.dart';
import 'package:focus/shared/widgets/app_drawer.dart';
import 'package:focus/shared/widgets/gesture_navigation.dart';
import 'package:provider/provider.dart';

/// Tela de configurações gerais do aplicativo.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeVM = context.watch<ThemeViewModel>();

    return AppGestureNavigation(
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBarWidget(
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.onPrimary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        drawer: const AppDrawer(),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurações',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: SwitchListTile(
                      secondary: Icon(
                        themeVM.isDarkMode
                            ? Icons.dark_mode_outlined
                            : Icons.light_mode_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: const Text(
                        'Modo escuro',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        themeVM.isDarkMode
                            ? 'Tema escuro ativado'
                            : 'Tema claro ativado',
                        style: const TextStyle(color: AppColors.textMuted),
                      ),
                      value: themeVM.isDarkMode,
                      activeThumbColor: theme.colorScheme.primary,
                      onChanged: (_) => themeVM.toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
