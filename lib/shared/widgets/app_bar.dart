import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/shared/utils/logout.dart';
import 'package:provider/provider.dart';

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
        PopupMenuButton<String>(
          icon: const Icon(Icons.account_circle_outlined),
          position: PopupMenuPosition.under,
          offset: const Offset(0, 8),
          tooltip: 'Perfil',
          onSelected: (value) async {
            if (value == 'logout') {
              await logout(context, context.read<AuthViewModel>());
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'profile',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.person_outline),
                title: Text('Meu perfil'),
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'logout',
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.logout),
                title: Text('Sair'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
