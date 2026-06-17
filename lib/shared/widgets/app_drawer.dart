import 'package:flutter/material.dart';
import 'package:focus/features/auth/viewmodels/auth_view_model.dart';
import 'package:focus/shared/utils/logout.dart';
import 'package:focus/shared/widgets/app_version.dart';
import 'package:provider/provider.dart';

/// Drawer lateral customizado com navegação e dados da conta.
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
      Navigator.of(context).pop(); // Fecha o drawer primeiro
      Navigator.of(context).pushNamed(routeName);
    }

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // CABEÇALHO CUSTOMIZADO E CLEAN
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: theme.colorScheme.onPrimary,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 26,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // LISTA DE OPÇÕES ESTILIZADA (Material 3 Style)
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                children: [
                  _buildSectionHeader('Navegação'),
                  
                  _buildDrawerItem(
                    icon: Icons.hourglass_empty_rounded,
                    label: 'Modo Foco',
                    iconColor: Colors.amber,
                    theme: theme,
                    onTap: () => navigateTo('/focus'),
                  ),
                  _buildDrawerItem(
                    icon: Icons.assignment_outlined,
                    label: 'Minhas Tarefas',
                    theme: theme,
                    onTap: () => navigateTo('/tasks'),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
                  ),
                  
                  _buildSectionHeader('Preferências'),

                  _buildDrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Configurações',
                    theme: theme,
                    onTap: () => navigateTo('/settings'),
                  ),
                ],
              ),
            ),

            Divider(color: theme.dividerColor.withValues(alpha: 0.3)),

            // AÇÃO DE SAIR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: _buildDrawerItem(
                icon: Icons.logout_rounded,
                label: 'Sair',
                iconColor: Colors.redAccent,
                textColor: Colors.redAccent,
                theme: theme,
                onTap: () => logout(context, authVM),
              ),
            ),

            // VERSÃO DO APLICATIVO
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 20.0),
              child: Center(
                child: const AppVersion(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required ThemeData theme,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
        title: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor ?? theme.textTheme.bodyLarge?.color,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        horizontalTitleGap: 12,
        onTap: onTap,
      ),
    );
  }
}
