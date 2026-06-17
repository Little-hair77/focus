import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/features/profile/viewmodels/profile_view_model.dart';

/// AppBar padrão com logo, nome do app e atalho para perfil.
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
        Consumer2<ProfileViewModel, AuthViewModel>(
          builder: (context, profileVM, authVM, child) {
            final userName = authVM.userName ?? 'Usuário';
            final initial = userName.trim().isEmpty
                ? 'U'
                : userName[0].toUpperCase();

            return Semantics(
              button: true,
              label: 'Abrir perfil de $userName',
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed('/profile'),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4.0,
                    vertical: 8.0,
                  ),
                  child: ExcludeSemantics(
                    child: CircleAvatar(
                      radius: 18, // Tamanho ideal para encaixar na AppBar
                      backgroundColor: theme.colorScheme.onPrimary.withValues(
                        alpha: 0.2,
                      ),
                      // 🖼️ Se houver foto escolhida no dispositivo, exibe ela
                      backgroundImage: profileVM.imageFile != null
                          ? FileImage(profileVM.imageFile!)
                          : null,
                      // 🔤 Fallback: Se não houver foto, exibe a inicial do usuário em texto branco
                      child: profileVM.imageFile == null
                          ? Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12), // Espaçamento do canto da tela
      ],
    );
  }
}
