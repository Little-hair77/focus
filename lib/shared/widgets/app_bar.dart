import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;

  const AppBarWidget({super.key, this.leading});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: AppColors.onPrimary,
      iconTheme: const IconThemeData(color: AppColors.onPrimary),
      leading: leading,
      title: const Text(
        'Focus',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          color: AppColors.onPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, size: 28),
          tooltip: 'Meu Perfil',
          onPressed: () {
            // Navega direto para a tela de perfil usando a rota nomeada
            Navigator.of(context).pushNamed('/profile');
          },
        ),
        const SizedBox(width: 8), // Pequeno espaçamento do canto da tela
      ],
    );
  }
}